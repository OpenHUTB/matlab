function v=checkConverter(this)





    v=struct('Status',0,'Message','','MessageID','');

    if isempty(this.NCO)
        msg='Oscillator must be specified as NCO for HDL Code generation in Digital Up/Down Converter system objects';
        v=struct('Status',1,'Message',msg,'MessageID','HDLShared:hdlfilter:invalidOscillator');
        return
    end


