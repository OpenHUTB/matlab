classdef Population<hgsetget











    properties(Access=public)
        Name='';
    end

    properties(SetAccess=private)
        Individuals=[];
        Type='population';
VarNamer
    end


    methods

        function obj=Population(name,varNamer)
            obj.Name=name;
            obj.VarNamer=varNamer;
        end



        function[out,idLabel,timeLabel,dvLabel,doseLabel,rateLabel,contCovLabel,catCovLabel]=getLookupTable(obj)




            numIndividuals=length(obj.Individuals);




            if numIndividuals>=1
                reservedNames=obj.Individuals(1).ReservedNames;
            else
                reservedNames={};
            end
            idLabel=obj.VarNamer.getName('Group',reservedNames);

            dataMaps=cell(1,numIndividuals);
            for i=1:numIndividuals
                individual=obj.Individuals(i);
                [nextDataMap,timeLabel,dvLabel,doseLabel,rateLabel,contCovLabel,catCovLabel]=individual.getDataMap;
                name=individual.Name;

                if iscellstr(name)
                    name=name{1};
                end

                numRows=length(nextDataMap(timeLabel));

                if ischar(name)

                    ids=repmat({name},numRows,1);
                else
                    ids=repmat(name,numRows,1);
                end


                nextDataMap(idLabel)=ids;

                dataMaps{i}=nextDataMap;
            end


            variableNames=[idLabel,timeLabel,doseLabel,rateLabel,dvLabel,contCovLabel,catCovLabel];
            numVariables=length(variableNames);
            tableData=cell(1,numVariables);
            for i=1:numVariables
                thisVariable=variableNames{i};
                dataCell=cell(numIndividuals,1);
                for j=1:numIndividuals
                    dataCell{j}=dataMaps{j}(thisVariable);
                end
                data=vertcat(dataCell{:});
                tableData{i}=data;
            end
            out=table(tableData{:},'VariableNames',variableNames);







            for i=length(rateLabel):-1:1
                columnSum=sum(out.(rateLabel{i}));
                if columnSum==0
                    out.(rateLabel{i})=[];
                    rateLabel(i)=[];
                end
            end
        end



        function out=addIndividuals(obj,count)
            ind=cell(1,count);
            for i=1:count
                ind{i}=SimBiology.internal.Data.Individual('VarNamer',obj.VarNamer);
            end
            obj.Individuals=[ind{:}];
            out=obj.Individuals;
        end

    end
end