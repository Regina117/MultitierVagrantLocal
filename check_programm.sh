#!/bin/bash

# Проверка установки VirtualBox
if command -v virtualbox &> /dev/null
then
    echo "VirtualBox установлен: $(virtualbox --help | grep 'VirtualBox version')"
else
    echo "VirtualBox не установлен"
fi

# Проверка установки Vagrant
if command -v vagrant &> /dev/null
then
    echo "Vagrant установлен: $(vagrant --version)"
else
    echo "Vagrant не установлен"
fi

# Проверка установки Git
if command -v git &> /dev/null
then
    echo "Git установлен: $(git --version)"
else
    echo "Git не установлен"
fi

# Проверка установки JDK 8
if command -v java &> /dev/null
then
    java_version=$(java -version 2>&1 | head -n 1)
    if [[ "$java_version" == *"1.8"* ]]; then
        echo "JDK 8 установлен: $java_version"
    else
        echo "JDK 8 не установлен"
    fi
else
    echo "JDK 8 не установлен"
fi

# Проверка установки Maven
if command -v mvn &> /dev/null
then
    echo "Maven установлен: $(mvn -v)"
else
    echo "Maven не установлен"
fi

# Проверка установки IntelliJ IDEA
if command -v idea &> /dev/null
then
    echo "IntelliJ IDEA установлен: $(idea --version)"
else
    echo "IntelliJ IDEA не установлен"
fi

# Проверка установки Sublime Text
if command -v subl &> /dev/null
then
    echo "Sublime Text установлен"
else
    echo "Sublime Text не установлен"
fi
