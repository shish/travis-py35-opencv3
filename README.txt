Travis' version of ubuntu is ancient, so there is no python3-opencv
package D:

The image provided by travis doesn't have python 3.5 built-in, so we
need to build that for ourselves first...

Also opencv3 doesn't build properly with ancient cmake, so we get a
new cmake too.

With modern python and modern cmake installed into this ancient
ubuntu, we can then build opencv in ancient-ubuntu-compatible mode,
and then we can copy-paste that build into a real travis env.
