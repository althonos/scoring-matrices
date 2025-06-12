Matrices
========

.. currentmodule:: scoring_matrices

The following matrices are distributed with the ``scoring-matrices`` package
and can be loaded with `ScoringMatrix.from_name`:


3DI
    3di structural alphabet scoring matrix used in Foldseek.

    .. versionadded:: 0.3.1

BENNER6, BENNER22, BENNER74
    Matrices proposed in Benner, Cohen and Gonnet (1994). 

BLOSUM30, BLOSUM35, BLOSUM40, BLOSUM45, BLOSUM50, BLOSUM55, BLOSUM60, BLOSUM62, BLOSUM65, BLOSUM70, BLOSUM75, BLOSUM80, BLOSUM85, BLOSUM90, BLOSUM100, BLOSUMN
    BLOcks SUbstitution Matrix series, computed by Henikoff (1992) from databases
    of local alignments. BLOSUM62 is the default matrix used in the 
    BLAST algorithm.

DAYHOFF
    An alias for the PAM-250 with additional B, Z, X and \* scores.

GONNET 
    PAM 250 matrix recommended by Gonnet, Cohen & Benner (1992).

NUC.4.4 
    The extended DNA scoring matrix (sometimes also EDNAFULL) created by
    Todd Lowe (1992).

PAM10, PAM20, PAM30, PAM40, PAM50, PAM60, PAM70, PAM80, PAM90, PAM100, PAM110, PAM120, PAM130, PAM140, PAM150, PAM160, PAM170, PAM180, PAM190, PAM200, PAM210, PAM220, PAM230, PAM240, PAM250, PAM260, PAM270, PAM280, PAM290, PAM300, PAM310, PAM320, PAM330, PAM340, PAM350, PAM360, PAM370, PAM380, PAM390, PAM400, PAM410, PAM420, PAM430, PAM440, PAM450, PAM460, PAM470, PAM480, PAM490, PAM500
    Point-Accepted Mutation matrix series computed by Dayhoff (1966).

VTML10, VTML20, VTML40, VTML80, VTML120, VTML160
    Matrices computed with the *resolvent method* developed by Müller and Vingron
    to improve estimation of exchange frequencies. VTML80 is used by MMseqs2
    for the k-mer generation process.

