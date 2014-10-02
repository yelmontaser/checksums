SensioLabs Checksums (experimental)
===================================

This repository contains signed SHA1 for all releases made by Open-Source
projects managed by SensioLabs.

You can use these SHA1 to validate the libraries you installed via a Github ZIP
file or via Composer.

To check all dependencies installed by Composer, clone this repository and run
the ``check-vendors.sh`` script:

.. code-block:: bash

    $ PATH/TO/check-vendors.sh

It will output something along the lines of:

.. code-block:: text

    symfony/swiftmailer-bundle@v2.2.6                        OK  files signature
    symfony/symfony@v2.5.2                                   KO  files signature
    twig/extensions@v1.0.1                                   OK  files signature
    twig/twig@v1.15.0                                        OK  files signature
    white-october/pagerfanta-bundle@dev-master               --  unknown package
    willdurand/hateoas@1.0.x-dev                             --  unknown package

     1 packages are potentially corrupted.
     Check that you did not add/modify/delete some files.

You can also check a directory manually by following the following steps. As an
example, let's say I have a project using Symfony 2.4.2 (you can check the
version installed by Composer by running ``composer show -i``). The sha1s for
this specific version are available here:
https://raw.githubusercontent.com/sensiolabs/checksums/master/symfony/symfony/v2.4.2.txt.

This file is signed, so you first need to verify it:

.. code-block:: bash

    $ curl -O https://raw.githubusercontent.com/sensiolabs/checksums/master/symfony/symfony/v2.4.2.txt
    $ gpg --verify v2.4.2.txt

.. note::

    The key used to sign the sha1 files is ``0xeb8aa69a566c0795``

Now, you can check the validity of the files you downloaded:

.. code-block:: bash

    $ cd PATH/TO/vendor/symfony/symfony
    $ find . -type f -print0 | xargs -0 shasum | shasum

The sha1 displayed should match the one from the file you've just downloaded
(the one under the `files_sha1` entry.)
