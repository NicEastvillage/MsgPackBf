using System;
using MsgPackBf;
using System.Diagnostics;

namespace MsgPackBfTest
{
	class Program
	{
		public static void Main()
		{
			// Serialization
			uint8[] buffer = scope uint8[32];
			MsgPacker packer = scope MsgPacker(buffer);

			packer.WriteMapHeader(2);
			packer.Write("compact");
			packer.Write(true);
			packer.Write("schema");
			packer.Write(0);

			// Deserialization
			MsgUnpacker unpacker = scope MsgUnpacker(buffer);

			let count = (int)unpacker.ReadMapHeader();
			bool compact;
			int schema;

			for (int i < count)
			{
				let key = scope String();
				unpacker.ReadString(key);

				switch (key)
				{
				case "compact":
					compact = unpacker.ReadBool().Get();
				case "schema":
					schema = unpacker.ReadInt32().Get();
				default:
					// Unknown key
					Debug.WriteLine("Unknown key: {}", key);
				}
			}


			SerializationTests.PerformTests();

			Console.Write("Done! Press ENTER to continue");
			Console.In.Read();
		}
	}
}
