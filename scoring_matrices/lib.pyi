import typing
from typing import TypeVar, Type, Optional, TextIO, Sequence, ClassVar, Tuple, List

S = TypeVar("S")

class ScoringMatrix:
    DEFAULT_ALPHABET: ClassVar[str]
    @classmethod
    def from_name(cls: Type[S], name: str = "BLOSUM62") -> S: ...
    @classmethod
    def from_file(cls: Type[S], file: TextIO, name: Optional[str] = None) -> S: ...
    @classmethod
    def from_str(cls: Type[S], text: str, name: Optional[str] = None) -> S: ...
    @classmethod
    def from_diagonal(
        cls: Type[S],
        diagonal: Iterable[float],
        mismatch_score: float = 0.0,
        alphabet: str = DEFAULT_ALPHABET,
        name: Optional[str] = None,
    ) -> S: ...
    @classmethod
    def from_match_mismatch(
        cls: Type[S],
        match_score: float = 1.0,
        mismatch_score: float = -0.0,
        alphabet: str = DEFAULT_ALPHABET,
        name: Optional[str] = None,
    ) -> S: ...
    def __init__(
        self,
        matrix: Sequence[Sequence[float]],
        alphabet: str = DEFAULT_ALPHABET,
        name: Optional[str] = None,
    ): ...
    def __copy__(self: S) -> S: ...
    def __repr__(self) -> str: ...
    def __reduce_ex__(self, protocol: object) -> Tuple[object, ...]: ...
    def __len__(self) -> int: ...
    def __eq__(self, other: object) -> bool: ...
    @typing.overload
    def __getitem__(self, item: int) -> List[float]: ...
    @typing.overload
    def __getitem__(self, item: str) -> List[float]: ...
    @typing.overload
    def __getitem__(self, item: Tuple[int, int]) -> float: ...
    @typing.overload
    def __getitem__(self, item: Tuple[str, str]) -> float: ...
    def copy(self: S) -> S: ...
    def is_integer(self) -> bool: ...
    def is_symmetric(self) -> bool: ...
    def min(self) -> float: ...
    def max(self) -> float: ...
    def shuffle(self: S, alphabet: str) -> S: ...
