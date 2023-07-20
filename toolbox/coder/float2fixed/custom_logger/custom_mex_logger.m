%#codegen

function[data,bufferInfo]=custom_mex_logger(idx_in,val_in)
    coder.inline('never');
    coder.extrinsic('tostring');
    coder.allowpcode('plain');
    if 2==nargin
        if customCoderEnableLog(idx_in)
            if isnumeric(val_in)&&~isreal(val_in)
                generic_logger_complex(idx_in,val_in);
            elseif isstruct(val_in)
                generic_logger_struct(idx_in,val_in);
            else
                if~indexMapper('hasindex',idx_in)
                    actualIdx=indexMapper('mapit',idx_in,1);
                else
                    actualIdx=indexMapper('fetch',idx_in);
                end

                if~buffers('hasItem',actualIdx)
                    if isfi(val_in)
                        valNumerictypeStr=coder.const(tostring(numerictype(val_in)));
                        valFimathStr=coder.const(tostring(fimath(val_in)));
                    else
                        valNumerictypeStr='';
                        valFimathStr='';
                    end
                    buffers('initItem',actualIdx,get_buffer_template(coder.ignoreConst(class(val_in)),coder.ignoreConst(size(val_in)),coder.ignoreConst(~coder.internal.isConst(size(val_in))),coder.ignoreConst(valNumerictypeStr),coder.ignoreConst(valFimathStr)));
                end

                val_flat=val_in(:)';
                bytes=tobytes(val_flat);
                generic_logger_impl(actualIdx,bytes);
            end
        end
    elseif nargin==0&&(nargout==1||nargout==2)
        data=buffers('getBuffers');
        bufferInfo=indexMapper('getIndexMapping');
    end
end

function generic_logger_impl(idx_in,bytes)
    coder.varsize('bytes','val_flat',[1,inf]);
    idx=idx_in;

    if idx>1&&~isempty(bytes)
        buffers('appendBytes',idx,bytes);
    end
end


function generic_logger_impl_val(idx_in,val_in)
    coder.extrinsic('tostring');
    coder.varsize('bytes','val_flat',[1,inf]);
    idx=idx_in;

    if idx>1&&~isempty(val_in)
        if~buffers('hasItem',idx)
            if isfi(val_in)
                valNumerictypeStr=coder.const(tostring(numerictype(val_in)));
                valFimathStr=coder.const(tostring(fimath(val_in)));
            else
                valNumerictypeStr='';
                valFimathStr='';
            end
            buffers('initItem',idx,get_buffer_template(coder.ignoreConst(class(val_in)),coder.ignoreConst(size(val_in)),coder.ignoreConst(~coder.internal.isConst(size(val_in))),coder.ignoreConst(valNumerictypeStr),coder.ignoreConst(valFimathStr)));
        end

        val_flat=val_in(:)';
        bytes=tobytes(val_flat);
        buffers('appendBytes',idx,bytes);
    end
end

function bytes=tobytes(val_in)
    coder.varsize('bytes',[1,inf]);
    if isfi(val_in)
        ints=fi2sim(val_in);

        bytes=tobytes(ints(:)');
    elseif islogical(val_in)
        bytes=uint8(val_in);
    elseif isnumeric(val_in)
        bytes=typecast(val_in,'uint8');
    elseif ischar(val_in)


        bytes=typecast(cast(val_in,'uint32'),'uint8');
    else
        eml_assert(0,['Unsupported type ',class(val_in),' in generic_logger']);
    end
end

function S=get_buffer_template(valClass,valSize,valIsVarSize,valNumerictypeStr,valFimathStr)
    coder.varsize('S.Class','S.Dims','S.NumericType','S.Fimath','S.Data',[1,inf]);
    S.Class=valClass;
    S.Dims=valSize;
    S.Varsize=valIsVarSize;
    S.NumericType=valNumerictypeStr;
    S.Fimath=valFimathStr;

    S.Data=uint8(0);
    S.DataSize=uint32(1);
end

function S=getIndexMapTemplate(actualIdx,fieldNames)
    coder.varsize('S.FieldNames',[1,inf]);
    S.ActualIndex=actualIdx;
    S.FieldNames=fieldNames;
end

function actualIdx=indexMapper(action,staticIdx,numTotalFields,fieldNames)
    coder.varsize('pIndexMap',[1,inf]);


    persistent pIndexMap pBufferLen
    if isempty(pIndexMap)
        pIndexMap=getIndexMapTemplate(uint32(0),'');
        pBufferLen=uint32(1);
    end

    switch action
    case 'hasindex'
        if staticIdx>length(pIndexMap)

            actualIdx=false;
        else
            if pIndexMap(staticIdx).ActualIndex~=0
                actualIdx=true;
            else
                actualIdx=false;
            end
        end
    case 'mapit'
        v=pBufferLen+1;
        if staticIdx>length(pIndexMap)
            pIndexMap=[pIndexMap,repmat(pIndexMap(1),1,staticIdx-length(pIndexMap))];
        end
        pIndexMap(staticIdx).ActualIndex=v;
        if nargin>=4
            pIndexMap(staticIdx).FieldNames=fieldNames;
        end

        pBufferLen=pBufferLen+numTotalFields;

        actualIdx=v;


    case 'fetch'
        actualIdx=pIndexMap(staticIdx).ActualIndex;
    case 'getIndexMapping'
        actualIdx=pIndexMap;
    end

end

function out=buffers(action,idx,arg)

    persistent pBuffers
    if isempty(pBuffers)
        pBuffers=get_buffer_template(coder.ignoreConst('uint8'),coder.ignoreConst([1,1]),coder.ignoreConst(false),coder.ignoreConst(''),coder.ignoreConst(''));

        coder.varsize('pBuffers',[1,inf]);
    end

    switch action
    case 'hasItem'
        out=(idx<=numel(pBuffers))&&(pBuffers(idx).DataSize>1);

    case 'initItem'
        if idx>numel(pBuffers)
            pBuffers=[pBuffers,repmat(pBuffers(1),1,idx-numel(pBuffers))];
        end
        buffer=arg;
        pBuffers(idx)=buffer;

    case 'getBuffers'
        out=pBuffers;
        pBuffers=pBuffers(1);

    case 'appendBytes'
        bytes=arg;

        size=pBuffers(idx).DataSize;
        capacity=numel(pBuffers(idx).Data);
        if size+numel(bytes)>capacity
            newSize=max(capacity*2,size+numel(bytes));
            pBuffers(idx).Data=[pBuffers(idx).Data,zeros(1,newSize-capacity,'uint8')];
        end

        pBuffers(idx).Data(size:size+numel(bytes)-1)=bytes(:);
        pBuffers(idx).DataSize=size+numel(bytes);
    end
end

function generic_logger_complex(idx_in,val_in)
    if~indexMapper('hasindex',idx_in)
        actualIdx=indexMapper('mapit',idx_in,2,'_re:_im');
    else
        actualIdx=indexMapper('fetch',idx_in);
    end
    generic_logger_complex_impl(actualIdx,val_in);
end

function actualIdx=generic_logger_complex_impl(actualIdx,val_in)
    generic_logger_impl_val(actualIdx,real(val_in));
    generic_logger_impl_val(actualIdx+1,imag(val_in));
    actualIdx=actualIdx+2;
end


function generic_logger_struct(idx_in,val_in)
    if isempty(val_in)
        return;
    end

    [fieldNamesStr,numLogged]=parse_struct(val_in);
    if~indexMapper('hasindex',idx_in)
        actualIdx=indexMapper('mapit',idx_in,numLogged,fieldNamesStr);
    else
        actualIdx=indexMapper('fetch',idx_in);
    end

    generic_logger_struct_impl(actualIdx,val_in);
end

function fieldIdx=generic_logger_struct_impl(fieldIdx,val_in)
    nFields=eml_numfields(val_in);
    isAlwaysEmpty=coder.const(coder.internal.isConst(isempty(val_in))&&isempty(val_in));
    if nFields>0&&~isAlwaysEmpty

        for ii=coder.unroll(0:nFields-1)
            fieldname=eml_getfieldname(val_in,ii);


            fieldvalue=val_in(1).(fieldname);


            if isstruct(fieldvalue)

                fieldIdx=generic_logger_struct_impl(fieldIdx,fieldvalue);
            elseif~isreal(fieldvalue)
                fieldIdx=generic_logger_complex_impl(fieldIdx,fieldvalue);
            else
                generic_logger_impl_val(fieldIdx,fieldvalue);
                fieldIdx=fieldIdx+1;
            end
        end
    else

    end
end

function[fieldNamesStr,numFieldsLogged]=parse_struct(val_in)
    coder.inline('never');
    coder.varsize('fieldNamesStr');
    nFields=eml_numfields(val_in);
    isAlwaysEmpty=coder.const(coder.internal.isConst(isempty(val_in))&&isempty(val_in));
    fieldNamesStr=[];
    fieldNamesStr=[fieldNamesStr,'struct ('];
    numFieldsLogged=0;
    if nFields>0&&~isAlwaysEmpty

        for ii=coder.unroll(0:nFields-1)
            fieldname=eml_getfieldname(val_in,ii);
            fieldvalue=val_in(1).(fieldname);

            fieldId=coder.const(fieldname);

            if numFieldsLogged~=0
                fieldNamesStr=[fieldNamesStr,','];
            end

            fieldNamesStr=[fieldNamesStr,fieldId];

            if isstruct(fieldvalue)

                [tmp,nLogged]=parse_struct(fieldvalue);
                fieldNamesStr=[fieldNamesStr,'(',tmp,')'];
                numFieldsLogged=numFieldsLogged+nLogged;
            elseif~isreal(fieldvalue)
                fieldNamesStr=[fieldNamesStr,'(','_re:_im',')'];

                numFieldsLogged=numFieldsLogged+2;
            else
                numFieldsLogged=numFieldsLogged+1;
            end
        end
    else

    end
    fieldNamesStr=[fieldNamesStr,')'];
end

function out=customCoderEnableLog(buffId)
    coder.extrinsic('f2fCustomCoderEnableLogState');

    persistent pInit pEnabled
    if isempty(pInit)
        coder.varsize('pEnabled',[1,Inf]);
        pInit=false;

        pEnabled=pInit;
        pEnabled=[pEnabled,f2fCustomCoderEnableLogState()];
        pEnabled(1)=[];
    end

    currLen=numel(pEnabled);
    if buffId>currLen
        out=pInit;
    else
        out=pEnabled(buffId);
    end
end