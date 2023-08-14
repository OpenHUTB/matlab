classdef mFunctionDetails<handle



    properties
        name;
        localCalls;
        externalCalls;
        location;
    end


    methods
        function this=mFunctionDetails(name)
            this.name=name;
        end
    end

    methods

        function[result,fcnCallCount]=getMATreeReport(this,fcnCallCount,fcnCallLimit)







            fcnCallCount=fcnCallCount+1;

            if fcnCallCount>fcnCallLimit
                this.location.setColor('warn');
            end


            rows=numel(this.localCalls)+numel(this.externalCalls);
            if rows==0
                result=this.location;
                return;
            end


            result=ModelAdvisor.Table(rows,1);
            result.setCollapsibleMode('all');


            result.setHeading(this.location);


            for idx=1:numel(this.localCalls)
                [report,fcnCallCount]=...
                getMATreeReport(this.localCalls(idx),fcnCallCount,fcnCallLimit);
                result.setEntry(idx,1,report);
            end


            for idx=numel(this.localCalls)+1:rows
                [report,fcnCallCount]=getMATreeReport(...
                this.externalCalls(idx-numel(this.localCalls)),...
                fcnCallCount,fcnCallLimit);
                result.setEntry(idx,1,report);
            end

        end

        function print(this,fcnCallCount)

            offset='';
            offset2='';

            for idx=1:fcnCallCount
                offset=[offset,'-'];
                offset2=[offset2,' '];
            end
            disp([offset2,'|']);
            disp([offset2,offset,this.name]);

            fcnCallCount=fcnCallCount+1;

            for idx=1:numel(this.localCalls)
                print(this.localCalls(idx),fcnCallCount);
            end

            for idx=1:numel(this.externalCalls)
                print(this.externalCalls(idx),fcnCallCount);
            end

        end

    end

end

