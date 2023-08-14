function varargout=simulateModel(this)




    simCommand=['sim(''',bdroot(this.ModelName),''');'];




    varargout={evalin('caller',simCommand)};
