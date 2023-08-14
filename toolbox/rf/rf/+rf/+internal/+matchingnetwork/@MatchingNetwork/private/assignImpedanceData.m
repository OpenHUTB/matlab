



function[z,datatype,metadata]=assignImpedanceData(zData)




    z=convertStringsToChars(zData);
    if(isnumeric(z))
        if(isscalar(z))
            validateattributes(z,{'numeric'},{'scalar','finite','nonnan','>=',0});
            datatype='Constant';
            metadata=z;
        else

            validateattributes(z,{'numeric'},{'nrows',2,'ndims',2,'finite','nonnan'});
            impedances=squeeze(z(1,:));
            frequencies=squeeze(z(2,:));
            validateattributes(frequencies,{'numeric'},{'real','positive','increasing'});
            impedances2=zeros(1,1,length(impedances));
            impedances2(1,1,:)=impedances;
            zp=zparameters(impedances2,frequencies);
            datatype='SParamObject';
            metadata=z;
            z=sparameters(zp);
        end
    elseif isa(z,'char')&&~isempty(regexpi(z,'.[syz]1p$','once'))
        datatype='SParamObject';
        metadata=z;
        z=sparameters(z);



    elseif(isa(z,'function_handle'))
        datatype='FunctionHandle';
        metadata=z;

    elseif(isa(z,'circuit'))&&z.NumPorts==1
        datatype='CircuitObject';
        metadata=z;

    elseif(isa(z,'em.EmStructures'))
        datatype='AntennaObject';
        metadata=z;


    elseif any(arrayfun(@(x)isa(z,x),["z","s","y"]+"parameters"))&&...
        z.NumPorts==1
        datatype='SParamObject';
        metadata=z;
        z=sparameters(z);


    elseif isa(z,'rfckt.datafile')&&size(z.AnalyzedResult.S_Parameters,1)==1
        datatype='SParamObject';
        metadata=z;
        z=sparameters(z);


    elseif isa(z,'rfdata.data')&&size(z.S_Parameters,1)==1
        datatype='SParamObject';
        metadata=z;
        z=sparameters(z);



    elseif(isa(z,'rfckt.rfckt'))&&~isa(z,'rfckt.datafile')
        datatype='AnalyzeCapableCircuitObject';
        metadata=z;
    else

        error(message('rf:matchingnetwork:UnkSrcZType'));
    end
end
