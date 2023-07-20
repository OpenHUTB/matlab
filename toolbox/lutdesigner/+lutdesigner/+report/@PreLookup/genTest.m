

qeWorkingDir;


w=test.tools.slreportgen.report.TestWriter('PreLookup');


w.Superclass='matlab.unittest.TestCase';
w.TestDir=pwd;
w.SingleArgConstructor="PreLookup(prelookup)";

w.Checkout=false;


w.write;
