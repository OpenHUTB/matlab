function privgeneratehdl(filterobj,varargin)





    if~(builtin('license','checkout','Filter_Design_HDL_Coder'))
        error(message('hdlfilter:privgeneratehdl:nolicenseavailable'));
    end



    indices=strcmpi({varargin{1:2:end}},'generatehdltestbench');
    pos=1:2:2*length(indices);
    pos=pos(indices);

    indices_name=strcmpi({varargin{1:2:end}},'name');
    posname=1:2:2*length(indices_name);
    posname=posname(indices_name);


    no_tbname=~any(strcmpi({varargin{1:2:end}},'testbenchname'));

    if(~isempty(pos)&&~strcmpi(varargin{pos+1},'off'))&&...
no_tbname
        if~isempty(pos)
            varargin(end+1)={'testbenchname'};
            varargin(end+1)={[varargin{posname+1},'_tb']};
        elseif~isempty(inputname(1))
            varargin(end+1)={'testbenchname'};
            varargin(end+1)={[inputname(1),'_tb']};
        end
    end




    resrc=[PersistentHDLResource...
    ,struct('comp',filterobj,...
    'bom',containers.Map(),...
    'numInst',1)];
    PersistentHDLResource(resrc);

    if isa(filterobj,'dfilt.farrowlinearfd')||isa(filterobj,'dfilt.farrowfd')



        if~any(strcmpi(varargin,'filtersystemobject'))
            indices=strcmpi(varargin,'inputdatatype');
            pos=1:length(indices);
            pos=pos(indices);
            if~isempty(pos)

                if(pos==1)
                    varargin=varargin(3:end);
                else
                    varargin=cat(2,varargin(1:(pos-1)),varargin((pos+2):end));
                end
            end



            indfd=strcmpi(varargin,'fractionaldelaydatatype');
            posfd=1:length(indfd);
            posfd=posfd(indfd);
            if~isempty(posfd)

                if(posfd==1)
                    varargin=varargin(3:end);
                else
                    varargin=cat(2,varargin(1:(posfd-1)),varargin((posfd+2):end));
                end
            end
        end

        hF=createhdlfilter(filterobj);

    elseif isa(filterobj,'dfilt.basefilter')||isa(filterobj,'filtergroup.usrp2')

        hF=createhdlfilter(filterobj);

    else
        indices=strcmpi(varargin,'inputdatatype');
        pos=1:length(indices);
        pos=pos(indices);
        if isempty(pos)
            error(message('hdlfilter:privgeneratehdl:inputdatatypenotspecified'));
        else

        end
        inputnumerictype=varargin{pos+1};
        if~strcmpi(class(inputnumerictype),'embedded.numerictype')
            error(message('hdlfilter:privgeneratehdl:incorrectinputdatatype'));
        end
        hF=createhdlfilter(filterobj,inputnumerictype);
    end









    hF.setupCBSSetting(filterobj);




    hF.setHDLParameter('GenerateHDLTestbench','off');





    pvvalues=l_flattenPVPairs(varargin{:});

    hF.setHDLParameter(pvvalues{:});

    hF.generatehdlcode(filterobj,pvvalues{:});



    function pvvalues=l_flattenPVPairs(varargin)

        pvhascell=false;
        pvvalues={};
        for n=1:nargin
            if iscell(varargin{n})
                pvhascell=true;
            end
        end
        if pvhascell&&(rem(numel(varargin),2)~=0)


            for jj=1:length(varargin)
                if iscell(varargin{jj})
                    celledpvs=varargin{jj};
                    for ii=1:length(celledpvs)
                        pvvalues{end+1}=celledpvs{ii};
                    end
                else
                    pvvalues{end+1}=varargin{jj};
                end
            end
        else
            pvvalues=varargin;
        end



