
# 反编译
jad反编译命令：
```shell
jad -o -r -dD:\buffer\jar\out -sjava D:\buffer\jar\org\**\*.class
```
其它参数说明:

-o  - overwrite output files without confirmation (default: no) 无需确定覆写文件

-r  - restore package directory structrure 恢复包目录结构

-s <ext></ext>- output file extension (by default '.jad') 如果不设置为-sjava，则默认扩展名为.jad

注意-dF:\ 和 -sava 中间是没有空格的。

## fernflower反编译
[fernflower](https://github.com/fesh0r/fernflower)


# MANIFEST.MF
在计算机领域中，"manifest" 通常指的是一份清单或概要文件，用于描述一组文件或资源的内容和属性。在 Java 中，MANIFEST.MF 文件就是一种用于描述 JAR 文件中包含的类和资源的清单文件，其中包含了一些元数据信息和属性。

至于为什么要将清单文件命名为 "MANIFEST.MF"，可能是因为这个文件最早是在早期的 UNIX 系统中使用的，而在 UNIX 中，".manifest" 是一种用于描述软件包或文件集合的文件名后缀。因此，Java 在设计 JAR 文件时可能也采用了这个后缀，以便于与 UNIX 系统中的相关工具和标准兼容。而 ".MF" 则是指该文件的格式是基于 Manifest 文件格式（MF，Manifest File Format）的，这也是 JAR 文件格式中的一部分。

MANIFEST.MF 概述
MANIFEST.MF 文件是 Java 打包工具（如 jar、war、ear 等）中必须存在的一个文件，用于描述打包文件的元信息。它的主要作用有以下两个方面：

指定打包文件中的主类

MANIFEST.MF 文件中的 Main-Class 属性可以指定打包文件中的主类，这个主类将会在运行时被启动。当我们使用 java -jar 命令运行一个 JAR 文件时，Java 运行时会读取 MANIFEST.MF 文件，找到 Main-Class 属性指定的类，并执行该类的 main() 方法。
存储打包文件的元信息

MANIFEST.MF 文件中还可以包含其他自定义属性，用于存储打包文件的元信息。例如，可以指定打包文件的版本号、作者、描述信息等。这些属性可以在运行时被读取，以提供更多的应用程序信息。
除了可以由打包工具自动生成 MANIFEST.MF 文件之外，我们也可以手动创建和编辑该文件，以添加自定义的属性。例如，我们可以使用文本编辑器创建一个名为 MANIFEST.MF 的文件，然后将以下内容保存到该文件中：

MANIFEST.MF有哪些配置项
Manifest-Version
指定 MANIFEST.MF 文件的版本号。例如
Manifest-Version: 1.0

Main-Class
指定打包文件的主类。例如
Main-Class: com.example.MyMainClass

Class-Path
指定该 JAR 文件的类路径，以便在运行时加载其他类。例如：
Class-Path: lib/other.jar lib/some.jar

Created-By
指定生成该 JAR 文件的工具和版本号。例如：
Created-By: Apache Maven 3.6.3

Implementation-Title
指定该 JAR 文件的实现标题。例如：
Implementation-Title: My Application

Implementation-Version
指定该 JAR 文件的实现版本。例如
Implementation-Version: 1.0.0-SNAPSHOT

Implementation-Vendor
指定该 JAR 文件的实现厂商。例如：
Implementation-Vendor: Acme Corporation

Implementation-Vendor-Id
指定该 JAR 文件的实现厂商 ID。例如：
Implementation-Vendor-Id: com.acme

Specification-Title
指定该 JAR 文件的规范标题。例如：
Specification-Title: My Application API

Specification-Version
指定该 JAR 文件的规范版本。例如
Specification-Version: 1.0.0

Specification-Vendor
指定该 JAR 文件的规范厂商。例如
Specification-Vendor: Acme Corporation

Sealed
指定该 JAR 文件是否被封闭，即是否允许其他 JAR 文件修改该 JAR 文件中的类文件。例如：
Sealed: true

MANIFEST.MF是被谁读取解析的
在 Java 中，MANIFEST.MF 文件通常被 Java 虚拟机（JVM）或相关的工具读取和解析。

例如，当我们在命令行使用 "java -jar" 命令运行一个打包成 JAR 文件的 Java 应用程序时，JVM 会读取 JAR 文件中的 MANIFEST.MF 文件来确定应用程序的主类，从而启动应用程序。
此外，也有许多其他的工具和库可以读取和解析 MANIFEST.MF 文件，

例如 Maven 和 Gradle 等构建工具，以及一些用于操作 JAR 文件的 Java 库，如 Java Archive (JAR) API 等。这些工具和库通常会使用 Java 类库中的 java.util.jar.Manifest 类来解析 MANIFEST.MF 文件，并将其转换为 Java 对象，以便于后续的操作和使用
MANIFEST.MF是所有的jar包必须要有的吗
不是所有的 JAR 文件都必须要包含 MANIFEST.MF 文件。在 Java 中，JAR 文件可以包含两种类型的条目：一种是类文件，另一种是元数据文件（如 MANIFEST.MF）。如果 JAR 文件中不包含 MANIFEST.MF 文件，则默认使用一个空的 MANIFEST.MF 文件。

但是，在某些情况下，我们可能需要在 MANIFEST.MF 文件中指定一些属性，例如应用程序的主类，或者其他的元数据信息。在这种情况下，我们就需要手动创建一个 MANIFEST.MF 文件，并将其添加到 JAR 文件中。
