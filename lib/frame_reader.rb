class FrameReader
  include Enumerable

  def initialize(channels, sample_type, frames_count, frames_ptr)
    @channels = channels
    @sample_type = sample_type
    @size = frames_count * @channels
    @pointer = FFI::Pointer.new(@sample_type, frames_ptr)
  end

  attr_reader :size

  def each
    return enum_for(__method__) unless block_given?

    ffi_read = :"read_#{@sample_type}"

    (0...size).each do |index|
      yield @pointer[index].public_send(ffi_read)
    end
  end
end
