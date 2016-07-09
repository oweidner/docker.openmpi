# Build this image:  docker build -t mpi .
#

FROM ubuntu:14.04
# FROM phusion/baseimage

MAINTAINER Marco Zocca <zocca marco gmail>
# based on `docker.openmpi` by Ole Weidner <ole.weidner@ed.ac.uk>

ENV USER mpirun

ENV DEBIAN_FRONTEND=noninteractive \
    HOME=/home/${USER} 


RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends openssh-server python-mpi4py python-numpy python-virtualenv python-scipy gcc gfortran openmpi-checkpoint binutils

RUN mkdir /var/run/sshd
RUN echo 'root:mpirun' | chpasswd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

# ------------------------------------------------------------
# Add an 'mpirun' user
# ------------------------------------------------------------

RUN adduser --disabled-password --gecos "" ${USER} && \
    echo "${USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# ------------------------------------------------------------
# Set-Up SSH with our Github deploy key
# ------------------------------------------------------------

ENV SSHDIR ${HOME}/.ssh/

RUN mkdir -p ${SSHDIR}

ADD ssh/config ${SSHDIR}/config
ADD ssh/id_rsa.mpi ${SSHDIR}/id_rsa
ADD ssh/id_rsa.mpi.pub ${SSHDIR}/id_rsa.pub
ADD ssh/id_rsa.mpi.pub ${SSHDIR}/authorized_keys



RUN chmod -R 600 ${SSHDIR}* && \
    chown -R ${USER}:${USER} ${SSHDIR}

# ------------------------------------------------------------
# Copy MPI4PY example scripts
# ------------------------------------------------------------

ADD mpi4py_benchmarks ${HOME}/mpi4py_benchmarks
RUN chown ${USER}:${USER} ${HOME}/mpi4py_benchmarks


ADD run_tests.sh ${HOME}/mpi4py_benchmarks



EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
