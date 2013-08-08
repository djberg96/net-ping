require 'ffi'

module Windows
  extend FFI::Library
  ffi_lib :kernel32

  attach_function :GetVersion, [], :ulong

  def version
    version = GetVersion()
    major = LOBYTE(LOWORD(version))
    minor = HIBYTE(LOWORD(version))
    eval("Float(#{major}.#{minor})")
  end

  private

  class << self
    def LOWORD(l)
      l & 0xffff
    end

    def LOBYTE(w)
      w & 0xff
    end

    def HIBYTE(w)
      w >> 8
    end
  end

  module_function :version
end
