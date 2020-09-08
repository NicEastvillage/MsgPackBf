using System;
using MsgPackBf;
using System.Diagnostics;
using System.Collections;

namespace MsgPackBfTest
{
	class Program
	{
		[Reflect]
		public class TestClass
		{
			public InnerTestClass inner = new InnerTestClass() ~ delete _;
			public int i = 5;
			public float f = 42f;
		}

		[Reflect]
		public class InnerTestClass
		{
			public int k = -2;
		}

		public static void Main()
		{
			// Serialization
			uint8[] buffer = scope uint8[256];
			MsgPacker packer = scope MsgPacker(buffer);

			let list = scope List<int>();
			list.Add(5);
			list.Add(10);

			let outer = scope List<List<int>>();
			outer.Add(list);

			packer.Serialize(list);
			packer.Serialize(outer);

			let tc = scope TestClass();

			packer.SerializeObject(tc);

			let map = scope Dictionary<int, float>();
			map.Add(0, 0f);
			map.Add(1, 3.1415926535f);

			packer.Serialize(map);

			// Deserialization
			MsgUnpacker unpacker = scope MsgUnpacker(buffer);

			Console.Write("Done! Press ENTER to continue");
			Console.In.Read();
		}
	}
}
