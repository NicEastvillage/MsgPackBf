using System;
using MsgPackBf;
using System.Diagnostics;
using System.Collections;

namespace MsgPackBfTest
{
	class Program
	{
		[Reflect]
		class TestStruct
		{
			public int32 integer = 42;
			public String str = "Hello world";
			public InnerTest inner = new InnerTest() ~ delete _;
			public List<int> list = new List<int>() ~ delete _;
		}

		[Reflect]
		class InnerTest
		{
			public float scalar = 1.5f;
		}

		public static void Main()
		{
			// Serialization
			uint8[] buffer = scope uint8[256];
			MsgPacker packer = scope MsgPacker(buffer);

			let t = scope TestStruct();

			packer.Write(t);

			MsgUnpacker unpacker = scope MsgUnpacker(buffer);

			unpacker.ReadString(scope String()).Get(); // int32 integer = 42
			unpacker.ReadInt32().Get();
			unpacker.ReadString(scope String()).Get(); // String str = "Hello World"
			unpacker.ReadString(scope String()).Get();
			unpacker.ReadString(scope String()).Get(); // InnerTest inner = ..
			unpacker.ReadString(scope String()).Get(); // float scalar = 1.5f
			unpacker.ReadFloat().Get();

			SerializationTests.PerformTests();

			Console.Write("Done! Press ENTER to continue");
			Console.In.Read();
		}
	}
}
