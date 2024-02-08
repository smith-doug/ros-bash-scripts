#!/bin/bash
if [ -f /opt/ros/melodic/setup.bash ]; then
    export IS_MELODIC=1
fi
if [ -f /opt/ros/foxy/setup.bash ]; then
    export IS_FOXY=1
fi
if [ -f /opt/ros/galactic/setup.bash ]; then
    export IS_GALACTIC=1    
fi
if [ -f /opt/ros/kinetic/setup.bash ]; then
    export IS_KINETIC=1
fi
if [ -f /opt/ros/noetic/setup.bash ]; then
    export IS_NOETIC=1
fi
if [ -f /opt/ros/humble/setup.bash ]; then
    echo "Humble"
    export IS_HUMBLE=1
fi


if [ -f /.dockerenv ]; then
    export IS_DOCKER=1
    echo "docker"
fi

if [[ $IS_FOXY && $IS_GALACTIC ]]; then
    echo "Why do you have both foxy and galactic?  Defaulting to galactic.";
    unset IS_FOXY
fi

ros1source()
{
    if [[ $IS_NOETIC ]]; then
        source /opt/ros/noetic/setup.bash
    fi
    #local ws_path
    current_path=$(pwd -L)
    ws_path=$(catkin locate -w $current_path);

    if [ $? -eq 0 ]; then        

        #echo $ws_path;
        if [ -f "${ws_path}/install/setup.bash" ]; then
          echo "${ws_path}/install";
          source "${ws_path}/install/setup.bash";
        else
          echo "${ws_path}/devel";
          source "${ws_path}/devel/setup.bash";
        fi
    fi
}

ros2pipenv()
{
    ws_path=$1
    pip_activate="env/bin/activate"   

    if [[ $# -eq 1 && -f "${ws_path}/${pip_activate}" ]]; then
        echo "Sourcing pip env at ${ws_path}/${pip_activate}"
        . "${ws_path}/${pip_activate}"        
    else
        current_path=$(pwd -L)
        if [ -f ${current_path}/${pip_activate} ]; then
            echo "Sourcing pip env under current directory"
            . ${current_path}/${pip_activate}
        fi
    fi
}

ros2source()
{
    if [[ $IS_GALACTIC ]]; then
        echo "Sourcing Galactic"
        . ~/scripts/galactic/galactic.sh    
    elif [[ $IS_FOXY ]]; then
        echo "Sourcing Foxy";
        . /opt/ros/foxy/setup.bash;  
    elif [[ $IS_HUMBLE ]]; then
        echo "Sourcing humble"
        . ~/scripts/bash/humble.sh 
    fi

    current_path=$(pwd -L)
    if [[ $# -eq 0 ]]; then 
        ws_path=$(catkin locate -w $current_path);

        if [ $? -eq 0 ]; then 
            cd $ws_path;  
            colcon_cd --set
            cd $current_path        

            if [ -f "${ws_path}/install/setup.bash" ]; then
                echo "${ws_path}/install";
                source "${ws_path}/install/setup.bash";
            else
                echo "${ws_path}/devel";
                source "${ws_path}/devel/setup.bash";
            fi            

            ros2pipenv ${ws_path}           
        fi
    else
        ros2pipenv
    fi    
}