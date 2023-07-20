function checkResults(this)





    this.restoreFromMatFile('original Simulink signal log');
    this.restoreFromMatFile('TLM input vectors');
    this.restoreFromMatFile('TLM output vectors');
    this.tlmvec2sllog();
    this.compareSllogs();
    this.saveToMatFile('TLM results as Simulink signal log');

end
