classdef Variable<iofile.File














    properties
inMemStruct

    end

    methods

        function theVariable=Variable(varargin)

            theVariable=theVariable@iofile.File('');
            if nargin==1

                if isstruct(varargin{1})

                    theVariable.inMemStruct=varargin{1};

                end

            end
            theVariable.filterStruct.ALLOW_FOR_EACH=true;
            theVariable.filterStruct.ALLOW_EMPTY_DS=true;
            theVariable.filterStruct.ALLOW_EMPTY_TS=true;
            theVariable.filterStruct.ALLOW_DATASORE_MEM=true;
            theVariable.filterStruct.ALLOW_TIME_TABLE=true;
        end


        function validateFileName(~,~)

        end

        function varOut=loadAVariable(theVariable,varName)

            if isfield(theVariable.inMemStruct,varName)
                varOut.(varName)=theVariable.inMemStruct.(varName);
            else
                error('no variable with that name');
            end


        end

        function workSpaceData=load(theVariable)
            workSpaceData=theVariable.inMemStruct;
        end


        function aList=whos(theVariable)
            aList=struct;



            varNames=fieldnames(theVariable.inMemStruct);
            for k=1:length(varNames)
                aList(k).name=varNames{k};
                aList(k).class=class(theVariable.inMemStruct.(varNames{k}));
            end
        end


    end

end