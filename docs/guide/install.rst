Installation
============

.. note::

    Wheels are provided for x86-64 Linux, MacOS, and Windows, as well
    as Aarch64 Linux and MacOS, but other machines will have to build the 
    wheel from the source distribution. Building ``scoring-matrices`` involves 
    compiling some Cython code, which requires a C compiler to be available on 
    the local machine.


PyPi
^^^^

``scoring-matrices`` is hosted on GitHub, but the easiest way to install it is to download
the latest release from its `PyPi repository <https://pypi.python.org/pypi/scoring-matrices>`_.
It will install all build dependencies then install ``scoring-matrices`` 
either from a wheel if one is available, or from source after compiling the 
Cython code :

.. code:: console

   $ pip install --user scoring-matrices


Conda
^^^^^

`scoring-matrices` is also available as a `recipe <https://anaconda.org/bioconda/scoring-matrices>`_
in the `bioconda <https://bioconda.github.io/>`_ channel. To install, simply
use the ``conda`` installer:

.. code:: console

   $ conda install bioconda::scoring-matrices


Arch User Repository
^^^^^^^^^^^^^^^^^^^^

A package recipe for Arch Linux can be found in the Arch User Repository
under the name `python-scoring-matrices <https://aur.archlinux.org/packages/python-scoring-matrices>`_.
It will always match the latest release from PyPI.

Steps to install on ArchLinux depend on your `AUR helper <https://wiki.archlinux.org/title/AUR_helpers>`_
(``yaourt``, ``aura``, ``yay``, etc.). For ``aura``, you'll need to run:

.. code:: console

    $ aura -A python-scoring-matrices


Piwheels
^^^^^^^^

``scoring-matrices`` is compatible with Raspberry Pi computers, and pre-built 
wheels are compiled for `armv7l` platforms on `piwheels <https://www.piwheels.org>`_. 
Run the following command to install these instead of compiling from source:

.. code:: console

   $ pip3 install scoring-matrices --extra-index-url https://www.piwheels.org/simple

Check the `piwheels documentation <https://www.piwheels.org/faq.html>`_ for
more information.


GitHub + ``pip``
^^^^^^^^^^^^^^^^

If, for any reason, you prefer to download the library from GitHub, you can clone
the repository and install the repository by running (with the admin rights):

.. code:: console

   $ git clone --recursive https://github.com/althonos/scoring-matrices
   $ pip install --user ./scoring-matrices

.. caution::

    Keep in mind this will install always try to install the latest commit,
    which may not even build, so consider using a versioned release instead.


