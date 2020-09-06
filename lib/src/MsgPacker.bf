using System;
using System.Diagnostics;
using Digest.Serialize;

namespace MsgPackBf
{
	class MsgPacker : Serializer
	{
		Span<uint8> mBuffer;
		BufferStream mStream ~ delete _;

		public this(Span<uint8> buffer)
		{
			mBuffer = buffer;
			mStream = new BufferStream(buffer);
		}

		public int64 Length
		{
			get
			{
				return mStream.Position;
			}
		}

		public Result<void> SerializeNull()
		{
			return mStream.Write((uint8)0xc0);
		}

		public Result<void> SerializeBool(bool value)
		{
			return mStream.Write((uint8)(0xc2 | (value ? 1 : 0)));
		}

		public Result<void> SerializeUInt(uint value)
		{
			return SerializeUInt64((uint64)value);
		}

		public Result<void> SerializeUInt8(uint8 value)
		{
			if (value <= 127)
			{
				return EncodeFixuint(value);
			}
			else
			{
				return EncodeUint8(value);
			}
		}

		public Result<void> SerializeUInt16(uint16 value)
		{
			if (value <= 127)
			{
				return EncodeFixuint((uint8)value);
			}
			else if (value <= uint8.MaxValue)
			{
				return EncodeUint8((uint8)value);
			}
			else
			{
				return EncodeUint16(value);
			}
		}

		public Result<void> SerializeUInt32(uint32 value)
		{
			if (value <= 127)
			{
				return EncodeFixuint((uint8)value);
			}
			else if (value <= uint8.MaxValue)
			{
				return EncodeUint8((uint8)value);
			}
			else if (value <= uint16.MaxValue)
			{
				return EncodeUint16((uint16)value);
			}
			else
			{
				return EncodeUint32(value);
			}
		}

		public Result<void> SerializeUInt64(uint64 value)
		{
			if (value <= 127)
			{
				return EncodeFixuint((uint8)value);
			}
			else if (value <= uint8.MaxValue)
			{
				return EncodeUint8((uint8)value);
			}
			else if (value <= uint16.MaxValue)
			{
				return EncodeUint16((uint16)value);
			}
			else if (value <= uint32.MaxValue)
			{
				return EncodeUint32((uint32)value);
			}
			else
			{
				return EncodeUint64(value);
			}
		}

		public override Result<void> SerializeInt(int value)
		{
			return SerializeInt64((int64)value);
		}

		public Result<void> SerializeInt8(int8 value)
		{
			if (value >= -32)
			{
				return EncodeFixint(value);
			}
			else
			{
				return EncodeInt8(value);
			}
		}

		public Result<void> SerializeInt16(int16 value)
		{
			if (value >= -32)
			{
				// When value is positive (or negative and small), we use the uint/fixint encodings
				if (value <= 127)
				{
					return EncodeFixint((int8)value);
				}
				else if (value <= uint8.MaxValue)
				{
					return EncodeUint8((uint8)value);
				}
				else
				{
					return EncodeUint16((uint16)value);
				}
			}
			else if (value >= int8.MinValue)
			{
				return EncodeInt8((int8)value);
			}
			else
			{
				return EncodeInt16(value);
			}
		}

		public Result<void> SerializeInt32(int32 value)
		{
			if (value >= -32)
			{
				// When value is positive (or negative and small), we use the uint/fixint encodings
				if (value <= 127)
				{
					return EncodeFixint((int8)value);
				}
				else if (value <= uint8.MaxValue)
				{
					return EncodeUint8((uint8)value);
				}
				else if (value <= uint16.MaxValue)
				{
					return EncodeUint16((uint16)value);
				}
				else
				{
					return EncodeUint32((uint32)value);
				}
			}
			else if (value >= int8.MinValue)
			{
				return EncodeInt8((int8)value);
			}
			else if (value >= int16.MinValue)
			{
				return EncodeInt16((int16)value);
			}
			else
			{
				return EncodeInt32(value);
			}
		}

		public override Result<void> SerializeInt64(int64 value)
		{
			if (value >= -32)
			{
				// When value is positive (or negative and small), we use the uint/fixint encodings
				if (value <= 127)
				{
					return EncodeFixint((int8)value);
				}
				else if (value <= uint8.MaxValue)
				{
					return EncodeUint8((uint8)value);
				}
				else if (value <= uint16.MaxValue)
				{
					return EncodeUint16((uint16)value);
				}
				else if (value <= uint32.MaxValue)
				{
					return EncodeUint32((uint32)value);
				}
				else
				{
					return EncodeUint64((uint64)value);
				}
			}
			else if (value >= int8.MinValue)
			{
				return EncodeInt8((int8)value);
			}
			else if (value >= int16.MinValue)
			{
				return EncodeInt16((int16)value);
			}
			else if (value >= int32.MinValue)
			{
				return EncodeInt32((int32)value);
			}
			else
			{
				return EncodeInt64(value);
			}
		}

		public override Result<void> SerializeFloat(float value)
		{
			return EncodeFloat(value);
		}

		public Result<void> SerializeDouble(double value)
		{
			return EncodeDouble(value);
		}

		public override Result<MapSerializer> SerializeDictionary(int count)
		{
			if (count <= 15)
			{
				Try!(EncodeFixmap((uint8)count));
			}
			else if (count <= uint16.MaxValue)
			{
				Try!(EncodeMap16((uint16)count));
			}
			else
			{
				Try!(EncodeMap32((uint32)count));
			}
			return .Ok(new MsgPackCompound(this, count));
		}

		public override Result<ListSerializer> SerializeList(int count)
		{
			if (count <= 15)
			{
				Try!(EncodeFixarray((uint8)count));
			}
			else if (count <= uint16.MaxValue)
			{
				Try!(EncodeArray16((uint16)count));
			}
			else
			{
				Try!(EncodeArray32((uint32)count));
			}
			return .Ok(new MsgPackCompound(this, count));
		}

		public override Result<void> SerializeString(StringView str)
		{
			let len = str.Length;

			if (len <= 31)
			{
				Try!(EncodeFixstr((uint8)len));
				return mStream.Write(str);
			}
			else if (len <= uint8.MaxValue)
			{
				Try!(EncodeStr8((uint8)len));
				return mStream.Write(str);
			}
			else if (len <= uint16.MaxValue)
			{
				Try!(EncodeStr16((uint16)len));
				return mStream.Write(str);
			}
			else
			{
				Try!(EncodeStr32((uint32)len));
				return mStream.Write(str);
			}
		}

		protected override Result<ObjectSerializer> SerializeObject(String className)
		{
			return .Ok(new MsgPackObjectBuilder(this));
		}

		// TODO Composite types

		// ---- Encoding ---

		private Result<void> EncodeFixuint(uint8 value)
		{
			Debug.Assert(value <= 127);
			return mStream.Write(value);
		}

		private Result<void> EncodeUint8(uint8 value)
		{
			Debug.Assert(value > 127);
			Try!(mStream.Write((uint8)0xcc));
			return mStream.Write(value);
		}

		private Result<void> EncodeUint16(uint16 value)
		{
			Debug.Assert(value > uint8.MaxValue);
			Try!(mStream.Write((uint8)0xcd));
			Try!(mStream.Write((uint8)((value >> 8) & 0xff)));
			return mStream.Write((uint8)(value & 0xff));
		}

		private Result<void> EncodeUint32(uint32 value)
		{
			Debug.Assert(value > uint16.MaxValue);
			Try!(mStream.Write((uint8)0xce));
			Try!(mStream.Write((uint8)((value >> 24) & 0xff)));
			Try!(mStream.Write((uint8)((value >> 16) & 0xff)));
			Try!(mStream.Write((uint8)((value >> 8) & 0xff)));
			return mStream.Write((uint8)(value & 0xff));
		}

		private Result<void> EncodeUint64(uint64 value)
		{
			Debug.Assert(value > uint32.MaxValue);
			Try!(mStream.Write((uint8)0xcf));
			Try!(mStream.Write((uint8)((value >> 56) & 0xff)));
			Try!(mStream.Write((uint8)((value >> 48) & 0xff)));
			Try!(mStream.Write((uint8)((value >> 40) & 0xff)));
			Try!(mStream.Write((uint8)((value >> 32) & 0xff)));
			Try!(mStream.Write((uint8)((value >> 24) & 0xff)));
			Try!(mStream.Write((uint8)((value >> 16) & 0xff)));
			Try!(mStream.Write((uint8)((value >> 8) & 0xff)));
			return mStream.Write((uint8)(value & 0xff));
		}

		private Result<void> EncodeFixint(int8 value)
		{
			Debug.Assert(value >= -32);
			return mStream.Write(value);
		}

		private Result<void> EncodeInt8(int8 value)
		{
			Debug.Assert(value < -32);
			Try!(mStream.Write((uint8)0xd0));
			return mStream.Write(value);
		}

		private Result<void> EncodeInt16(int16 value)
		{
			Debug.Assert(value < int8.MinValue);
			Try!(mStream.Write((uint8)0xd1));
			Try!(mStream.Write((uint8)((value >> 8) & 0xff)));
			return mStream.Write((uint8)(value & 0xff));
		}

		private Result<void> EncodeInt32(int32 value)
		{
			Debug.Assert(value < int16.MinValue);
			Try!(mStream.Write((uint8)0xd2));
			Try!(mStream.Write((uint8)((value >> 24) & 0xff)));
			Try!(mStream.Write((uint8)((value >> 16) & 0xff)));
			Try!(mStream.Write((uint8)((value >> 8) & 0xff)));
			return mStream.Write((uint8)(value & 0xff));
		}

		private Result<void> EncodeInt64(int64 value)
		{
			Debug.Assert(value < int32.MinValue);
			Try!(mStream.Write((uint8)0xd3));
			Try!(mStream.Write((uint8)((value >> 56) & 0xff)));
			Try!(mStream.Write((uint8)((value >> 48) & 0xff)));
			Try!(mStream.Write((uint8)((value >> 40) & 0xff)));
			Try!(mStream.Write((uint8)((value >> 32) & 0xff)));
			Try!(mStream.Write((uint8)((value >> 24) & 0xff)));
			Try!(mStream.Write((uint8)((value >> 16) & 0xff)));
			Try!(mStream.Write((uint8)((value >> 8) & 0xff)));
			return mStream.Write((uint8)(value & 0xff));
		}

		[Union]
		private struct FloatToUint8
		{
			public float f;
			public double d;
			public uint8[8] u;
		}

		private Result<void> EncodeFloat(float value)
		{
			Try!(mStream.Write((uint8)0xca));
			let v = scope FloatToUint8();
			v.f = value;
			Try!(mStream.Write(v.u[3]));
			Try!(mStream.Write(v.u[2]));
			Try!(mStream.Write(v.u[1]));
			return mStream.Write(v.u[0]);
		}

		private Result<void> EncodeDouble(double value)
		{
			Try!(mStream.Write((uint8)0xcb));
			let v = scope FloatToUint8();
			v.d = value;
			Try!(mStream.Write(v.u[7]));
			Try!(mStream.Write(v.u[6]));
			Try!(mStream.Write(v.u[5]));
			Try!(mStream.Write(v.u[4]));
			Try!(mStream.Write(v.u[3]));
			Try!(mStream.Write(v.u[2]));
			Try!(mStream.Write(v.u[1]));
			return mStream.Write(v.u[0]);
		}

		private Result<void> EncodeFixarray(uint8 count)
		{
			Debug.Assert(count <= 15);
			return mStream.Write((uint8)(0x90 | count));
		}

		private Result<void> EncodeArray16(uint16 count)
		{
			Debug.Assert(count > 15);
			Try!(mStream.Write((uint8)0xdc));
			Try!(mStream.Write((uint8)((count >> 8) & 0xff)));
			return mStream.Write((uint8)(count & 0xff));
		}

		private Result<void> EncodeArray32(uint32 count)
		{
			Debug.Assert(count > int16.MaxValue);
			Try!(mStream.Write((uint8)0xdd));
			Try!(mStream.Write((uint8)((count >> 24) & 0xff)));
			Try!(mStream.Write((uint8)((count >> 16) & 0xff)));
			Try!(mStream.Write((uint8)((count >> 8) & 0xff)));
			return mStream.Write((uint8)(count & 0xff));
		}

		private Result<void> EncodeFixmap(uint8 count)
		{
			Debug.Assert(count <= 15);
			return mStream.Write((uint8)(0x80 | count));
		}

		private Result<void> EncodeMap16(uint16 count)
		{
			Debug.Assert(count > 15);
			Try!(mStream.Write((uint8)0xde));
			Try!(mStream.Write((uint8)((count >> 8) & 0xff)));
			return mStream.Write((uint8)(count & 0xff));
		}

		private Result<void> EncodeMap32(uint32 count)
		{
			Debug.Assert(count > uint16.MaxValue);
			Try!(mStream.Write((uint8)0xdf));
			Try!(mStream.Write((uint8)((count >> 24) & 0xff)));
			Try!(mStream.Write((uint8)((count >> 16) & 0xff)));
			Try!(mStream.Write((uint8)((count >> 8) & 0xff)));
			return mStream.Write((uint8)(count & 0xff));
		}

		private Result<void> EncodeFixstr(uint8 len)
		{
			Debug.Assert(len <= 31);
			return mStream.Write((uint8)(0xa0 | len));
		}

		private Result<void> EncodeStr8(uint8 len)
		{
			Debug.Assert(len > 31);
			Try!(mStream.Write((uint8)0xd9));
			return mStream.Write(len);
		}

		private Result<void> EncodeStr16(uint16 len)
		{
			Debug.Assert(len > uint8.MaxValue);
			Try!(mStream.Write((uint8)0xda));
			Try!(mStream.Write((uint8)((len >> 8) & 0xff)));
			return mStream.Write((uint8)(len & 0xff));
		}

		private Result<void> EncodeStr32(uint32 len)
		{
			Debug.Assert(len > int16.MaxValue);
			Try!(mStream.Write((uint8)0xdb));
			Try!(mStream.Write((uint8)((len >> 24) & 0xff)));
			Try!(mStream.Write((uint8)((len >> 16) & 0xff)));
			Try!(mStream.Write((uint8)((len >> 8) & 0xff)));
			return mStream.Write((uint8)(len & 0xff));
		}

		private Result<void> EncodeBin8(uint8 len)
		{
			Debug.Assert(len > 31);
			Try!(mStream.Write((uint8)0xc4));
			return mStream.Write(len);
		}

		private Result<void> EncodeBin16(uint16 len)
		{
			Debug.Assert(len > uint8.MaxValue);
			Try!(mStream.Write((uint8)0xc5));
			Try!(mStream.Write((uint8)((len >> 8) & 0xff)));
			return mStream.Write((uint8)(len & 0xff));
		}

		private Result<void> EncodeBin32(uint32 len)
		{
			Debug.Assert(len > int16.MaxValue);
			Try!(mStream.Write((uint8)0xc6));
			Try!(mStream.Write((uint8)((len >> 24) & 0xff)));
			Try!(mStream.Write((uint8)((len >> 16) & 0xff)));
			Try!(mStream.Write((uint8)((len >> 8) & 0xff)));
			return mStream.Write((uint8)(len & 0xff));
		}
	}

	public class MsgPackCompound : ListSerializer, MapSerializer
	{
		private MsgPacker mPacker;
		private int mCount = 0;
		private int mExpectedCount;

		public this(MsgPacker packer, int expectedCount)
		{
			mPacker = packer;
			mExpectedCount = expectedCount;
		}

		public Result<void> SerializeElement(Serializable element)
		{
			mCount++;
			return mPacker.Serialize(element);
		}

		public Result<void> SerializeKeyValuePair(Serializable key, Serializable value)
		{
			mCount++;
			Try!(mPacker.Serialize(key));
			return mPacker.Serialize(value);
		}

		public Result<void> End()
		{
			if (mCount != mExpectedCount)
				return .Err;
			return .Ok;
		}
	}

	public class MsgPackObjectBuilder : ObjectSerializer
	{
		private MsgPacker mPacker;

		public this(MsgPacker packer)
		{
			mPacker = packer;
		}

		public Result<void> SerializeField(String fieldName, Serializable value)
		{
			Try!(mPacker.SerializeString(fieldName));
			return mPacker.Serialize(value);
		}

		public Result<void> End()
		{
			return .Ok;
		}
	}
}
