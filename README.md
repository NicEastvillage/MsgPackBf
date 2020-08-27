# MsgPackBf

A [MsgPack](https://msgpack.org/) library for [Beef](https://www.beeflang.org/) programming language.

This library is work in progress.

TODO:
- Serialization and deserialization of binary format
- Serialization and deserialization using reflection
- Support for extension types
- More tests, especially for deserialization

## Repository

In this repository you will find two folders:
- `lib` is the MsgPackBf library.
- `test` is a program to test MsgPackBf.

## How to use MsgPackBf

Serializing an object/map with the following structure `{"compact":true,"schema":0}`:

```C#
uint8[] buffer = scope uint8[32];
MsgPacker packer = scope MsgPacker(buffer);

packer.WriteMapHeader(2);
packer.Write("compact");
packer.Write(true);
packer.Write("schema");
packer.Write(0);
```

Afterwards `buffer` will contain your data and `packer.Length` is how many bytes are used.

Deserializing the same object/map:

```C#
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
	}
}
```

## How to get MsgPackBf

To add MsgPackBf to your project:

1. Clone the MsgPackBf library to a location of your choise.
1. In Beef IDE, right click on Workspace->Add existing project.
1. Select the `BeefProj.toml` file from the MsgPackBf/lib project.
1. Open your project's properties. Go to General->Dependencies.
1. Tick MsgPackBf.
1. You can now start using the library.