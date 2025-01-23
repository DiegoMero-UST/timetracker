class TimeRecordsController < ApplicationController
  def index
    @users = User.all
    @time_record = TimeRecord.new
    @todays_records = TimeRecord.includes(:user)
                               .where(date: Date.current)
                               .order(clock_in: :desc)
  end

  def clock_in
    Rails.logger.debug "Params received: #{params.inspect}" # Para debug

    return render_error("Seleccione un usuario") if params[:user_id].blank?

    @user = User.find(params[:user_id])
    @time_record = TimeRecord.new(
      user: @user,
      date: Date.current,
      clock_in: Time.current
    )

    Rails.logger.debug "Time Record: #{@time_record.inspect}" # Para debug
    Rails.logger.debug "Valid?: #{@time_record.valid?}" # Para debug
    Rails.logger.debug "Errors: #{@time_record.errors.full_messages}" if @time_record.invalid? # Para debug

    respond_to do |format|
      if @time_record.save
        format.turbo_stream { 
          render turbo_stream: [
            turbo_stream.update('flash_messages', 
              partial: 'shared/flash_messages', 
              locals: { notice: 'Entrada registrada exitosamente' }),
            turbo_stream.update('time_records_table',
              partial: 'time_records_table',
              locals: { todays_records: TimeRecord.includes(:user)
                                                .where(date: Date.current)
                                                .order(clock_in: :desc) })
          ]
        }
        format.html { redirect_to time_records_path, notice: 'Entrada registrada exitosamente' }
      else
        format.turbo_stream { 
          render turbo_stream: turbo_stream.update('flash_messages', 
            partial: 'shared/flash_messages', 
            locals: { alert: "Error al registrar entrada: #{@time_record.errors.full_messages.join(', ')}" })
        }
        format.html { redirect_to time_records_path, alert: "Error al registrar entrada: #{@time_record.errors.full_messages.join(', ')}" }
      end
    end
  end

  def clock_out
    @user = User.find(params[:user_id])
    @time_record = TimeRecord.find_by(
      user: @user,
      date: Date.current,
      clock_out: nil
    )

    respond_to do |format|
      if @time_record&.update(clock_out: Time.current)
        format.turbo_stream { 
          render turbo_stream: [
            turbo_stream.update('flash_messages', 
              partial: 'shared/flash_messages', 
              locals: { notice: 'Salida registrada exitosamente' }),
            turbo_stream.update('time_records_table',
              partial: 'time_records_table',
              locals: { todays_records: TimeRecord.includes(:user)
                                                .where(date: Date.current)
                                                .order(clock_in: :desc) })
          ]
        }
        format.html { redirect_to time_records_path, notice: 'Salida registrada exitosamente' }
      else
        format.turbo_stream { 
          render turbo_stream: turbo_stream.update('flash_messages', 
            partial: 'shared/flash_messages', 
            locals: { alert: 'Error al registrar salida' })
        }
        format.html { redirect_to time_records_path, alert: 'Error al registrar salida' }
      end
    end
  end

  private

  def render_error(message)
    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: turbo_stream.update('flash_messages',
          partial: 'shared/flash_messages',
          locals: { alert: message })
      }
      format.html { redirect_to time_records_path, alert: message }
    end
  end
end