using System;
using MsgPackBf;
using System.Diagnostics;
using System.Collections;

namespace MsgPackBfTest
{
	class Program
	{
		public static void Main()
		{
			// Serialization
			uint8[] buffer = scope uint8[32];
			MsgPacker packer = scope MsgPacker(buffer);

			let list = scope List<int>();
			list.Add(5);
			list.Add(10);

			Tuple<int, int> t;

			let outer = scope List<List<int>>();
			outer.Add(list);

			packer.Serialize(list);
			packer.Serialize(outer);

			// Deserialization
			MsgUnpacker unpacker = scope MsgUnpacker(buffer);

			Console.Write("Done! Press ENTER to continue");
			Console.In.Read();
		}
	}
}
