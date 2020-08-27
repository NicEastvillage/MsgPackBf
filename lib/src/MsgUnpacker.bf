using System;
namespace MsgPackBf
{
	class MsgUnpacker
	{
		Span<uint8> mBuffer;
		BufferStream mStream ~ delete _;

		public this(Span<uint8> buffer)
		{
			mBuffer = buffer;
			mStream = new BufferStream(buffer);
		}

		public int64 Remaining
		{
			get
			{
				return mBuffer.Length - mStream.Position;
			}
		}

		public Result<bool> ReadBool()
		{
			uint8 b = Try!(DecodeUint8());
			if (b == 0xc2) return .Ok(true);
			if (b == 0xc3) return .Ok(false);
			return .Err;
		}

		public Result<uint8> ReadUint8()
		{
			uint8 b = Try!(DecodeUint8());
			// Fixint?
			if (b < 128) return .Ok(b);
			if (b == 0xcc) return DecodeUint8();
			return .Err;
		}

		public Result<uint16> ReadUint16()
		{
			uint8 b = Try!(DecodeUint8());
			// Fixint?
			if (b < 128) return b;
			if (b == 0xcc) return Try!(DecodeUint8());
			if (b == 0xcd) return DecodeUint16();
			return .Err;
		}

		public Result<uint32> ReadUint32()
		{
			uint8 b = Try!(DecodeUint8());
			// Fixint?
			if (b < 128) return b;
			if (b == 0xcc) return Try!(DecodeUint8());
			if (b == 0xcd) return Try!(DecodeUint16());
			if (b == 0xce) return DecodeUint32();
			return .Err;
		}

		public Result<uint64> ReadUint64()
		{
			uint8 b = Try!(DecodeUint8());
			// Fixint?
			if (b < 128) return b;
			if (b == 0xcc) return Try!(DecodeUint8());
			if (b == 0xcd) return Try!(DecodeUint16());
			if (b == 0xce) return Try!(DecodeUint32());
			if (b == 0xcf) return DecodeUint64();
			return .Err;
		}

		public Result<int8> ReadInt8()
		{
			uint8 b = Try!(DecodeUint8());
			// Fixint?
			if (b < 128 || 224 <= b) return (int8)b;
			if (b == 0xcc || b == 0xd0) return (int8)Try!(DecodeUint8());
			return .Err;
		}

		public Result<int16> ReadInt16()
		{
			uint8 b = Try!(DecodeUint8());
			// Fixint?
			if (b < 128 || 224 <= b) return (int16)b;
			if (b == 0xcc || b == 0xd0) return (int16)Try!(DecodeUint8());
			if (b == 0xcd || b == 0xd1) return (int16)Try!(DecodeUint16());
			return .Err;
		}

		public Result<int32> ReadInt32()
		{
			uint8 b = Try!(DecodeUint8());
			// Fixint?
			if (b < 128 || 224 <= b) return (int32)b;
			if (b == 0xcc || b == 0xd0) return (int32)Try!(DecodeUint8());
			if (b == 0xcd || b == 0xd1) return (int32)Try!(DecodeUint16());
			if (b == 0xce || b == 0xd2) return (int32)Try!(DecodeUint32());
			return .Err;
		}

		public Result<int64> ReadInt64()
		{
			uint8 b = Try!(DecodeUint8());
			// Fixint?
			if (b < 128 || 224 <= b) return (int64)b;
			if (b == 0xcc || b == 0xd0) return (int64)Try!(DecodeUint8());
			if (b == 0xcd || b == 0xd1) return (int64)Try!(DecodeUint16());
			if (b == 0xce || b == 0xd2) return (int64)Try!(DecodeUint32());
			if (b == 0xcf || b == 0xd3) return (int64)Try!(DecodeUint64());
			return .Err;
		}

		public Result<float> ReadFloat()
		{
			uint8 b = Try!(DecodeUint8());
			if (b == 0xca) return Try!(DecodeFloat());
			return .Err;
		}

		public Result<double> ReadDouble()
		{
			uint8 b = Try!(DecodeUint8());
			if (b == 0xcb) return Try!(DecodeDouble());
			return .Err;
		}

		// ---- Decoding ---

		private Result<uint8> DecodeUint8()
		{
			return mStream.TryReadByte();
		}

		private Result<uint16> DecodeUint16()
		{
			uint16 x = 0;
			x |= (uint16)Try!(mStream.TryReadByte()) << 8;
			x |= (uint16)Try!(mStream.TryReadByte());
			return x;
		}

		private Result<uint32> DecodeUint32()
		{
			uint32 x = 0;
			x |= (uint32)Try!(mStream.TryReadByte()) << 24;
			x |= (uint32)Try!(mStream.TryReadByte()) << 16;
			x |= (uint32)Try!(mStream.TryReadByte()) << 8;
			x |= (uint32)Try!(mStream.TryReadByte());
			return x;
		}

		private Result<uint64> DecodeUint64()
		{
			uint64 x = 0;
			x |= (uint64)Try!(mStream.TryReadByte()) << 56;
			x |= (uint64)Try!(mStream.TryReadByte()) << 48;
			x |= (uint64)Try!(mStream.TryReadByte()) << 40;
			x |= (uint64)Try!(mStream.TryReadByte()) << 32;
			x |= (uint64)Try!(mStream.TryReadByte()) << 24;
			x |= (uint64)Try!(mStream.TryReadByte()) << 16;
			x |= (uint64)Try!(mStream.TryReadByte()) << 8;
			x |= (uint64)Try!(mStream.TryReadByte());
			return x;
		}

		[Union]
		private struct UintToFloat
		{
			public float f;
			public double d;
			public uint64 u;
		}

		private Result<float> DecodeFloat()
		{
			let v = scope UintToFloat();
			v.u = Try!(DecodeUint32());
			return v.f;
		}

		private Result<double> DecodeDouble()
		{
			let v = scope UintToFloat();
			v.u = Try!(DecodeUint64());
			return v.d;
		}
	}
}
