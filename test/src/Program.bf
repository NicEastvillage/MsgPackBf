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
			public InnerTest inner = new InnerTest() ~ delete _;
			public List<int> list = new List<int>() ~ delete _;
		}

		[Reflect]
		class InnerTest
		{
			public float scalar;
		}

		public static void Main()
		{
			// Serialization
			uint8[] buffer = scope uint8[256];
			MsgPacker packer = scope MsgPacker(buffer);

			let t = scope TestStruct();
			t.inner.scalar = 1.5f;

			packer.Write(t);

			MsgUnpacker unpacker = scope MsgUnpacker(buffer);

			unpacker.ReadFloat().Get();
			//unpacker.ReadInt32().Get();

			SerializationTests.PerformTests();

			Console.Write("Done! Press ENTER to continue");
			Console.In.Read();
		}
	}
}
