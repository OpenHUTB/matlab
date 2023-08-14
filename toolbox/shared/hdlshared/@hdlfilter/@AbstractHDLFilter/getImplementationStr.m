function impstr=getImplementationStr(this)








    archtype=this.Implementation;
    commentchars=this.getHDLParameter('comment_char');

    impstr=[commentchars,' HDL Implementation :'];
    switch(archtype)
    case{'serial','parallel'}
        if strcmpi(archtype,'serial')
            sp=this.getHDLParameter('filter_serialsegment_inputs');
            uff=this.getHDLParameter('userspecified_foldingfactor');
            nummults=this.getHDLParameter('filter_nummultiplier');
        else
            sp=-1;
            uff=1;
            nummults=-1;
        end
        ser_spt=this.isSerialSupported;
        if(ser_spt.fullyserial)
            if isa(this,'hdlfilter.abstractsos')
                if nummults~=-1
                    if uff~=1
                        error(message('HDLShared:hdlfilter:badserialspec'));

                    else
                        [ff,mults]=this.getSerialPartition('multiplier',nummults);
                    end
                else
                    if uff>=1
                        [ff,mults]=this.getSerialPartition('foldingfactor',uff);
                    else

                        error(message('HDLShared:hdlfilter:nopropsspecified'));
                    end
                end

            else
                cs=this.getHDLParameter('filter_coefficient_source');
                if~isempty(cs)
                    [~,ff,mults]=this.getSerialPartition('SerialPartition',sp,'CoefficientSource',cs);
                else
                    [~,ff,mults]=this.getSerialPartition('SerialPartition',sp);
                end
            end
            if(mults==1)
                archtypestr='Fully Serial';
            else
                archtypestr='Partly Serial';
            end
            if strcmpi(archtype,'parallel')
                archtypestr='Fully parallel';
            end
            impstr=[commentchars,' HDL Implementation    : ',archtypestr,'\n',...
            commentchars,...
            ' Folding Factor        : ',num2str(ff),'\n'];
        else
            archtypestr='Fully parallel';
            impstr=[commentchars,' HDL Implementation    : ',archtypestr,'\n'];
        end

    case{'serialcascade'}
        archtypestr='Cascade serial';
        impstr=[commentchars,' HDL Implementation    : ',archtypestr,'\n',...
        commentchars,'\n'];
    case 'distributedarithmetic'
        archtypestr='Distributed arithmetic (DA)';
        lutin=this.getHDLParameter('filter_dalutpartition');
        drin=this.getHDLParameter('filter_daradix');
        [dp,~,lutsize,ff]=this.getDALutPartition('DARadix',...
        drin,'DALUTPartition',lutin);
        archaddrwidth=dp(1);
        impstr=[commentchars,' HDL Implementation    : ',archtypestr,'\n',...
        commentchars,...
        ' Folding Factor        : ',num2str(ff),'\n',...
        commentchars,...
        ' LUT Address Width     : ',num2str(archaddrwidth),'\n',...
        commentchars,...
        ' Total LUT Size (bits) : ',num2str(lutsize),'\n'];
    end

