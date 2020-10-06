using System;
using MsgPackBf;
using System.Diagnostics;
using System.Collections;
using Digest.Serialize;

namespace MsgPackBfTest
{
	class Program
	{
		public class TestClass : Serialized
		{
			public InnerTest inner;
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
