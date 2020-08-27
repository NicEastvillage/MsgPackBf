using System;
using MsgPackBf;
using System.Diagnostics;

namespace MsgPackBfTest
{
	class Program
	{
		public static void Main()
		{
			uint8[] buffer = scope uint8[6];
			MsgPacker packer = scope MsgPacker(buffer);

			const float x = 1.5f;
			packer.Write(x);

			MsgUnpacker unpacker = scope MsgUnpacker(buffer);
			Debug.Assert(x == unpacker.ReadFloat().Get());

			TestUint01();
			TestUint02();
			TestUint03();
			TestInt01();
			TestInt02();
			TestFloat01();
			TestFloat02();
			TestMap01();
			TestArray01();
			TestArray02();

			Console.Write("Done! Press ENTER to continue");
			Console.In.Read();
		}

		private static void TestUint01()
		{
			// Various fixuints
			Console.Write("Testing uint 01 .. ");

			uint8[] buffer = scope uint8[6];
			MsgPacker packer = scope MsgPacker(buffer);

			packer.Write(0);
			packer.Write(2);
			packer.Write(17);
			packer.Write(63);
			packer.Write(65);
			packer.Write(120);

			Debug.Assert(buffer[0] == (uint8)0x00);
			Debug.Assert(buffer[1] == (uint8)0x02);
			Debug.Assert(buffer[2] == (uint8)0x11);
			Debug.Assert(buffer[3] == (uint8)0x3f);
			Debug.Assert(buffer[4] == (uint8)0x41);
			Debug.Assert(buffer[5] == (uint8)0x78);

			Console.WriteLine("ok");
		}

		private static void TestUint02()
		{
			// Various fixuints
			Console.Write("Testing uint 01 .. ");

			uint8[] buffer = scope uint8[5];
			MsgPacker packer = scope MsgPacker(buffer);

			packer.Write((uint)5);
			packer.Write((uint8)6);
			packer.Write((uint16)7);
			packer.Write((uint32)8);
			packer.Write((uint64)9);

			Debug.Assert(buffer[0] == (uint8)0x05);
			Debug.Assert(buffer[1] == (uint8)0x06);
			Debug.Assert(buffer[2] == (uint8)0x07);
			Debug.Assert(buffer[3] == (uint8)0x08);
			Debug.Assert(buffer[4] == (uint8)0x09);

			Console.WriteLine("ok");
		}

		private static void TestUint03()
		{
			// Fixuint vs uint8 vs uint16 vs uint32 vs uint64
			Console.Write("Testing uint 02 .. ");

			uint8[] buffer = scope uint8[39];
			MsgPacker packer = scope MsgPacker(buffer);

			packer.Write(127);
			packer.Write(128);

			packer.Write((uint16)uint8.MaxValue);
			packer.Write((uint16)uint8.MaxValue + 1);

			packer.Write((uint32)uint16.MaxValue);
			packer.Write((uint32)uint16.MaxValue + 1);

			packer.Write((uint64)uint32.MaxValue);
			packer.Write((uint64)uint32.MaxValue + 1);

			packer.Write(uint64.MaxValue);

			Debug.Assert(buffer[0] == (uint8)0x7f);
			Debug.Assert(buffer[1] == (uint8)0xcc);
			Debug.Assert(buffer[2] == (uint8)0x80);

			Debug.Assert(buffer[3] == (uint8)0xcc);
			Debug.Assert(buffer[4] == (uint8)0xff);
			Debug.Assert(buffer[5] == (uint8)0xcd);
			Debug.Assert(buffer[6] == (uint8)0x01);
			Debug.Assert(buffer[7] == (uint8)0x00);

			Debug.Assert(buffer[8] == (uint8)0xcd);
			Debug.Assert(buffer[9] == (uint8)0xff);
			Debug.Assert(buffer[10] == (uint8)0xff);
			Debug.Assert(buffer[11] == (uint8)0xce);
			Debug.Assert(buffer[12] == (uint8)0x00);
			Debug.Assert(buffer[13] == (uint8)0x01);
			Debug.Assert(buffer[14] == (uint8)0x00);
			Debug.Assert(buffer[15] == (uint8)0x00);

			Debug.Assert(buffer[16] == (uint8)0xce);
			Debug.Assert(buffer[17] == (uint8)0xff);
			Debug.Assert(buffer[18] == (uint8)0xff);
			Debug.Assert(buffer[19] == (uint8)0xff);
			Debug.Assert(buffer[20] == (uint8)0xff);
			Debug.Assert(buffer[21] == (uint8)0xcf);
			Debug.Assert(buffer[22] == (uint8)0x00);
			Debug.Assert(buffer[23] == (uint8)0x00);
			Debug.Assert(buffer[24] == (uint8)0x00);
			Debug.Assert(buffer[25] == (uint8)0x01);
			Debug.Assert(buffer[26] == (uint8)0x00);
			Debug.Assert(buffer[27] == (uint8)0x00);
			Debug.Assert(buffer[28] == (uint8)0x00);
			Debug.Assert(buffer[29] == (uint8)0x00);

			Debug.Assert(buffer[30] == (uint8)0xcf);
			Debug.Assert(buffer[31] == (uint8)0xff);
			Debug.Assert(buffer[32] == (uint8)0xff);
			Debug.Assert(buffer[33] == (uint8)0xff);
			Debug.Assert(buffer[34] == (uint8)0xff);
			Debug.Assert(buffer[35] == (uint8)0xff);
			Debug.Assert(buffer[36] == (uint8)0xff);
			Debug.Assert(buffer[37] == (uint8)0xff);
			Debug.Assert(buffer[38] == (uint8)0xff);

			Console.WriteLine("ok");
		}

		private static void TestInt01()
		{
			// Small negative integers
			Console.Write("Testing int 01 .. ");

			uint8[] buffer = scope uint8[5];
			MsgPacker packer = scope MsgPacker(buffer);

			packer.Write((int)-1);
			packer.Write((int8)-1);
			packer.Write((int16)-1);
			packer.Write((int32)-1);
			packer.Write((int64)-1);

			Debug.Assert(buffer[0] == (uint8)0xff);
			Debug.Assert(buffer[1] == (uint8)0xff);
			Debug.Assert(buffer[2] == (uint8)0xff);
			Debug.Assert(buffer[3] == (uint8)0xff);
			Debug.Assert(buffer[4] == (uint8)0xff);

			Console.WriteLine("ok");
		}

		private static void TestInt02()
		{
			// Negative numbers, Fixint vs int8 vs int16 vs int32 vs int64
			Console.Write("Testing int 02 .. ");

			uint8[] buffer = scope uint8[39];
			MsgPacker packer = scope MsgPacker(buffer);

			packer.Write(-32);
			packer.Write(-33);

			packer.Write(int8.MinValue);
			packer.Write(int8.MinValue - 1);

			packer.Write(int16.MinValue);
			packer.Write(int16.MinValue - 1);

			packer.Write((int64)int32.MinValue);
			packer.Write((int64)int32.MinValue - 1);

			// Note: Beef's in64.MinValue is 0x8000000000000001 instead of 0x8000000000000000
			packer.Write(int64.MinValue - 1);

			Debug.Assert(buffer[0] == (uint8)0xe0);
			Debug.Assert(buffer[1] == (uint8)0xd0);
			Debug.Assert(buffer[2] == (uint8)0xdf);
			
			Debug.Assert(buffer[3] == (uint8)0xd0);
			Debug.Assert(buffer[4] == (uint8)0x80);
			Debug.Assert(buffer[5] == (uint8)0xd1);
			Debug.Assert(buffer[6] == (uint8)0xff);
			Debug.Assert(buffer[7] == (uint8)0x7f);
			
			Debug.Assert(buffer[8] == (uint8)0xd1);
			Debug.Assert(buffer[9] == (uint8)0x80);
			Debug.Assert(buffer[10] == (uint8)0x00);
			Debug.Assert(buffer[11] == (uint8)0xd2);
			Debug.Assert(buffer[12] == (uint8)0xff);
			Debug.Assert(buffer[13] == (uint8)0xff);
			Debug.Assert(buffer[14] == (uint8)0x7f);
			Debug.Assert(buffer[15] == (uint8)0xff);
			
			Debug.Assert(buffer[16] == (uint8)0xd2);
			Debug.Assert(buffer[17] == (uint8)0x80);
			Debug.Assert(buffer[18] == (uint8)0x00);
			Debug.Assert(buffer[19] == (uint8)0x00);
			Debug.Assert(buffer[20] == (uint8)0x00);
			Debug.Assert(buffer[21] == (uint8)0xd3);
			Debug.Assert(buffer[22] == (uint8)0xff);
			Debug.Assert(buffer[23] == (uint8)0xff);
			Debug.Assert(buffer[24] == (uint8)0xff);
			Debug.Assert(buffer[25] == (uint8)0xff);
			Debug.Assert(buffer[26] == (uint8)0x7f);
			Debug.Assert(buffer[27] == (uint8)0xff);
			Debug.Assert(buffer[28] == (uint8)0xff);
			Debug.Assert(buffer[29] == (uint8)0xff);
			
			Debug.Assert(buffer[30] == (uint8)0xd3);
			Debug.Assert(buffer[31] == (uint8)0x80);
			Debug.Assert(buffer[32] == (uint8)0x00);
			Debug.Assert(buffer[33] == (uint8)0x00);
			Debug.Assert(buffer[34] == (uint8)0x00);
			Debug.Assert(buffer[35] == (uint8)0x00);
			Debug.Assert(buffer[36] == (uint8)0x00);
			Debug.Assert(buffer[37] == (uint8)0x00);
			Debug.Assert(buffer[38] == (uint8)0x00);
			
			Console.WriteLine("ok");
		}

		private static void TestFloat01()
		{
			Console.Write("Testing float 01 .. ");

			uint8[] buffer = scope uint8[5];
			MsgPacker packer = scope MsgPacker(buffer);

			packer.Write(-1.75f);

			Debug.Assert(buffer[0] == (uint8)0xca);
			Debug.Assert(buffer[1] == (uint8)0xbf);
			Debug.Assert(buffer[2] == (uint8)0xe0);
			Debug.Assert(buffer[3] == (uint8)0x00);
			Debug.Assert(buffer[4] == (uint8)0x00);

			Console.WriteLine("ok");
		}

		private static void TestFloat02()
		{
			Console.Write("Testing float 02 .. ");

			uint8[] buffer = scope uint8[5];
			MsgPacker packer = scope MsgPacker(buffer);

			packer.Write(38.5010529f);

			Debug.Assert(buffer[0] == (uint8)0xca);
			Debug.Assert(buffer[1] == (uint8)0x42);
			Debug.Assert(buffer[2] == (uint8)0x1a);
			Debug.Assert(buffer[3] == (uint8)0x01);
			Debug.Assert(buffer[4] == (uint8)0x14);

			Console.WriteLine("ok");
		}

		private static void TestMap01()
		{
			Console.Write("Testing map 01 .. ");

			uint8[] buffer = scope uint8[20];
			MsgPacker packer = scope MsgPacker(buffer);

			packer.BeginMap(2);
			packer.Write("compact");
			packer.Write(true);
			packer.Write("schema");
			packer.Write(0);

			Debug.Assert(buffer[0] == (uint8)0x82);
			Debug.Assert(buffer[1] == (uint8)0xa7);
			Debug.Assert(buffer[2] == (uint8)0x63);
			Debug.Assert(buffer[3] == (uint8)0x6f);
			Debug.Assert(buffer[4] == (uint8)0x6d);
			Debug.Assert(buffer[5] == (uint8)0x70);
			Debug.Assert(buffer[6] == (uint8)0x61);
			Debug.Assert(buffer[7] == (uint8)0x63);
			Debug.Assert(buffer[8] == (uint8)0x74);
			Debug.Assert(buffer[9] == (uint8)0xc3);
			Debug.Assert(buffer[10] == (uint8)0xa6);
			Debug.Assert(buffer[11] == (uint8)0x73);
			Debug.Assert(buffer[12] == (uint8)0x63);
			Debug.Assert(buffer[13] == (uint8)0x68);
			Debug.Assert(buffer[14] == (uint8)0x65);
			Debug.Assert(buffer[15] == (uint8)0x6d);
			Debug.Assert(buffer[16] == (uint8)0x61);
			Debug.Assert(buffer[17] == (uint8)0x00);

			Console.WriteLine("ok");
		}

		private static void TestArray01()
		{
			// Small arrays
			Console.Write("Testing array 01 .. ");

			uint8[] buffer = scope uint8[256];
			MsgPacker packer = scope MsgPacker(buffer);

			for (let l < 15)
			{
				packer.BeginArray((uint8)l);
				for (let i < l)
				{
					packer.Write(i);
				}
			}

			var b = 0;
			for (let l < 15)
			{
				Debug.Assert(buffer[b++] == (uint8)(0x90 | l));
				for (let i < l)
				{
					Debug.Assert(buffer[b++] == (uint8)i);
				}
			}

			Console.WriteLine("ok");
		}

		private static void TestArray02()
		{
			// Medium and big arrays
			Console.Write("Testing array 02 .. ");

			uint8[] buffer = scope uint8[14];
			MsgPacker packer = scope MsgPacker(buffer);

			// No content packed
			packer.BeginArray((uint16)16);
			packer.BeginArray(uint16.MaxValue);
			packer.BeginArray((uint32)uint16.MaxValue);
			packer.BeginArray((uint32)uint16.MaxValue + 1);

			Debug.Assert(buffer[0] == (uint8)0xdc);
			Debug.Assert(buffer[1] == (uint8)0x00);
			Debug.Assert(buffer[2] == (uint8)0x10);

			Debug.Assert(buffer[3] == (uint8)0xdc);
			Debug.Assert(buffer[4] == (uint8)0xff);
			Debug.Assert(buffer[5] == (uint8)0xff);

			Debug.Assert(buffer[6] == (uint8)0xdc);
			Debug.Assert(buffer[7] == (uint8)0xff);
			Debug.Assert(buffer[8] == (uint8)0xff);

			Debug.Assert(buffer[9] == (uint8)0xdd);
			Debug.Assert(buffer[10] == (uint8)0x00);
			Debug.Assert(buffer[11] == (uint8)0x01);
			Debug.Assert(buffer[12] == (uint8)0x00);
			Debug.Assert(buffer[13] == (uint8)0x00);

			Console.WriteLine("ok");
		}
	}
}
