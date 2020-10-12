using System;
using MsgPackBf;
using System.Diagnostics;
using System.Collections;
using Digest.Serialize;

namespace MsgPackBfTest
{
	class Program
	{
		public struct SuperTestClass : Serialized
		{
			public int superint = 101;
		}

		public struct TestClass : SuperTestClass, Serialized
		{
			public int i = 1;
			public int8 i8 = 2;
			public int16 i16 = 3;
			public int32 i32 = 4;
			public int64 i64 = 5;
			public uint u = 6;
			public uint8 u8 = 7;
			public uint16 u16 = 8;
			public uint32 u32 = 9;
			public uint64 u64 = 10;
			public char8 c8 = 'a';
			public char16 c16 = 'b';
			public float f = 11.0f;
			public double d = 12.0;
			public bool b = true;
			public InnerTest inner;
			//public TestClass child = null;
		}

		public struct InnerTest : Serialized
		{
			public String s = "123test";
		}

		public static void Main()
		{
			// Serialization
			uint8[] buffer = scope uint8[256];
			MsgPacker packer = scope MsgPacker(buffer);

			let tc = scope TestClass();

			packer.SerializeObject(tc);


			// Deserialization
			MsgUnpacker unpacker = scope MsgUnpacker(buffer);

			Console.Write("Done! Press ENTER to continue");
			Console.In.Read();
		}
	}
}
