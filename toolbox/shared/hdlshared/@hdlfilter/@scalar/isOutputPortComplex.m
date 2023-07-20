function success=isOutputPortComplex(this)





    success=~isreal(this.Gain)||this.getHDLParameter('filter_complex_inputs');