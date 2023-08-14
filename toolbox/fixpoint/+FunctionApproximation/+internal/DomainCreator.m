classdef DomainCreator













    properties
        Domains={};
    end

    methods
        function this=DomainCreator(grid)


            this.Domains=cell(numel(grid{1})-1,1);
            for ii=1:size(this.Domains,1)
                this.Domains{ii}=[grid{1}(ii),grid{1}(ii+1)];
            end

            for ii=2:numel(grid)

                other=FunctionApproximation.internal.DomainCreator(grid(ii));
                this=combine(this,other);
            end
        end
    end

    methods(Access=private)
        function this=combine(this,other)
            domains=cell(1,numel(this.Domains)*numel(other.Domains));
            count=1;
            for ii=1:numel(this.Domains)
                for jj=1:numel(other.Domains)
                    domains{count}=[this.Domains{ii};other.Domains{jj}];
                    count=count+1;
                end
            end

            this.Domains=domains;
        end
    end
end