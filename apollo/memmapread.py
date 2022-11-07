from io import TextIOWrapper
import mmap 

class MemoryMappedFileReader:
    def __init__(self, path: str):
        self.path: str = path 
        self.file: TextIOWrapper = None 
        self.mmap: mmap.mmap = None 

    def open_read(self):
        self.file = open(self.path, 'r+b')
        self.mmap = mmap.mmap(self.file.fileno(), 0)

    def read_integer(self) -> int:
        length_as_bytes = self.read_bytes(4)
        return int.from_bytes(length_as_bytes, byteorder='little')

    def read_bytes(self, length: int) -> bytes:
        self.mmap.seek(0)
        return self.mmap.read(length)

    def close(self):
        if self.file is not None:
            self.file.close()
        if self.mmap is not None:
            self.mmap.close()

mmf_reader = MemoryMappedFileReader('/tmp/apollo/input')
mmf_len_reader = MemoryMappedFileReader('/tmp/apollo/input_length')

mmf_reader.open_read()
mmf_len_reader.open_read()

#triggered via posix signal ( new input )
length = mmf_len_reader.read_integer()
content = mmf_reader.read_bytes(length)
