�ڼ���������У�"manifest" ͨ��ָ����һ���嵥���Ҫ�ļ�����������һ���ļ�����Դ�����ݺ����ԡ��� Java �У�MANIFEST.MF �ļ�����һ���������� JAR �ļ��а����������Դ���嵥�ļ������а�����һЩԪ������Ϣ�����ԡ�

����ΪʲôҪ���嵥�ļ�����Ϊ "MANIFEST.MF"����������Ϊ����ļ������������ڵ� UNIX ϵͳ��ʹ�õģ����� UNIX �У�".manifest" ��һ������������������ļ����ϵ��ļ�����׺����ˣ�Java ����� JAR �ļ�ʱ����Ҳ�����������׺���Ա����� UNIX ϵͳ�е���ع��ߺͱ�׼���ݡ��� ".MF" ����ָ���ļ��ĸ�ʽ�ǻ��� Manifest �ļ���ʽ��MF��Manifest File Format���ģ���Ҳ�� JAR �ļ���ʽ�е�һ���֡�

MANIFEST.MF ����
MANIFEST.MF �ļ��� Java ������ߣ��� jar��war��ear �ȣ��б�����ڵ�һ���ļ���������������ļ���Ԫ��Ϣ��������Ҫ�����������������棺

ָ������ļ��е�����

MANIFEST.MF �ļ��е� Main-Class ���Կ���ָ������ļ��е����࣬������ཫ��������ʱ��������������ʹ�� java -jar ��������һ�� JAR �ļ�ʱ��Java ����ʱ���ȡ MANIFEST.MF �ļ����ҵ� Main-Class ����ָ�����࣬��ִ�и���� main() ������
�洢����ļ���Ԫ��Ϣ

MANIFEST.MF �ļ��л����԰��������Զ������ԣ����ڴ洢����ļ���Ԫ��Ϣ�����磬����ָ������ļ��İ汾�š����ߡ�������Ϣ�ȡ���Щ���Կ���������ʱ����ȡ�����ṩ�����Ӧ�ó�����Ϣ��
���˿����ɴ�������Զ����� MANIFEST.MF �ļ�֮�⣬����Ҳ�����ֶ������ͱ༭���ļ���������Զ�������ԡ����磬���ǿ���ʹ���ı��༭������һ����Ϊ MANIFEST.MF ���ļ���Ȼ���������ݱ��浽���ļ��У�

MANIFEST.MF����Щ������
Manifest-Version
ָ�� MANIFEST.MF �ļ��İ汾�š�����
Manifest-Version: 1.0

Main-Class
ָ������ļ������ࡣ����
Main-Class: com.example.MyMainClass

Class-Path
ָ���� JAR �ļ�����·�����Ա�������ʱ���������ࡣ���磺
Class-Path: lib/other.jar lib/some.jar

Created-By
ָ�����ɸ� JAR �ļ��Ĺ��ߺͰ汾�š����磺
Created-By: Apache Maven 3.6.3

Implementation-Title
ָ���� JAR �ļ���ʵ�ֱ��⡣���磺
Implementation-Title: My Application

Implementation-Version
ָ���� JAR �ļ���ʵ�ְ汾������
Implementation-Version: 1.0.0-SNAPSHOT

Implementation-Vendor
ָ���� JAR �ļ���ʵ�ֳ��̡����磺
Implementation-Vendor: Acme Corporation

Implementation-Vendor-Id
ָ���� JAR �ļ���ʵ�ֳ��� ID�����磺
Implementation-Vendor-Id: com.acme

Specification-Title
ָ���� JAR �ļ��Ĺ淶���⡣���磺
Specification-Title: My Application API

Specification-Version
ָ���� JAR �ļ��Ĺ淶�汾������
Specification-Version: 1.0.0

Specification-Vendor
ָ���� JAR �ļ��Ĺ淶���̡�����
Specification-Vendor: Acme Corporation

Sealed
ָ���� JAR �ļ��Ƿ񱻷�գ����Ƿ��������� JAR �ļ��޸ĸ� JAR �ļ��е����ļ������磺
Sealed: true

MANIFEST.MF�Ǳ�˭��ȡ������
�� Java �У�MANIFEST.MF �ļ�ͨ���� Java �������JVM������صĹ��߶�ȡ�ͽ�����

���磬��������������ʹ�� "java -jar" ��������һ������� JAR �ļ��� Java Ӧ�ó���ʱ��JVM ���ȡ JAR �ļ��е� MANIFEST.MF �ļ���ȷ��Ӧ�ó�������࣬�Ӷ�����Ӧ�ó���
���⣬Ҳ����������Ĺ��ߺͿ���Զ�ȡ�ͽ��� MANIFEST.MF �ļ���

���� Maven �� Gradle �ȹ������ߣ��Լ�һЩ���ڲ��� JAR �ļ��� Java �⣬�� Java Archive (JAR) API �ȡ���Щ���ߺͿ�ͨ����ʹ�� Java ����е� java.util.jar.Manifest �������� MANIFEST.MF �ļ���������ת��Ϊ Java �����Ա��ں����Ĳ�����ʹ��
MANIFEST.MF�����е�jar������Ҫ�е���
�������е� JAR �ļ�������Ҫ���� MANIFEST.MF �ļ����� Java �У�JAR �ļ����԰����������͵���Ŀ��һ�������ļ�����һ����Ԫ�����ļ����� MANIFEST.MF������� JAR �ļ��в����� MANIFEST.MF �ļ�����Ĭ��ʹ��һ���յ� MANIFEST.MF �ļ���

���ǣ���ĳЩ����£����ǿ�����Ҫ�� MANIFEST.MF �ļ���ָ��һЩ���ԣ�����Ӧ�ó�������࣬����������Ԫ������Ϣ������������£����Ǿ���Ҫ�ֶ�����һ�� MANIFEST.MF �ļ�����������ӵ� JAR �ļ��С�
��������������������������������
��Ȩ����������ΪCSDN������G̽���ߡ���ԭ�����£���ѭCC 4.0 BY-SA��ȨЭ�飬ת���븽��ԭ�ĳ������Ӽ���������
ԭ�����ӣ�https://blog.csdn.net/qq_34050399/article/details/129222527