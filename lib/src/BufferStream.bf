using System;
using System.IO;

namespace MsgPackBf
{
	class BufferStream : Stream
	{
		Span<uint8> mBuffer;
		int mPosition = 0;

		public this(Span<uint8> buffer) {
			mBuffer = buffer;
		}

		public override int64 Position
		{
			get
			{
				return mPosition;
			}

			set
			{
				mPosition = (.)value;
			}
		}

		public override int64 Length
		{
			get
			{
				return mBuffer.Length;
			}
		}

		public override bool CanRead
		{
			get
			{
				return true;
			}
		}

		public override bool CanWrite
		{
			get
			{
				return true;
			}
		}

		public Result<uint8> TryReadByte()
		{
			if (mBuffer.Length - mPosition <= 0)
				return .Err;
			
			return .Ok(mBuffer[mPosition++]);
		}

		public override Result<int> TryRead(Span<uint8> data)
		{
			let count = data.Length;
			if (count == 0)
				return .Ok(0);
			int readBytes = Math.Min(count, mBuffer.Length - mPosition);
			if (readBytes <= 0)
				return .Ok(readBytes);

			Internal.MemCpy(data.Ptr, &mBuffer[mPosition], readBytes);
			mPosition += readBytes;
			return .Ok(readBytes);
		}

		public override Result<int> TryWrite(Span<uint8> data)
		{
			let count = data.Length;
			if (count == 0)
				return .Ok(0);
			let remaining = mBuffer.Length - mPosition;
			if (count > remaining)
				return .Err;
			Internal.MemCpy(&mBuffer[mPosition], data.Ptr, count);
			mPosition += count;
			return .Ok(count);
		}

		public override void Close()
		{
			
		}
	}
}
