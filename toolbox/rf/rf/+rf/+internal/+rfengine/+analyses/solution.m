classdef solution




    properties
        Circuit=[]
        X=[]
        Frequencies=[]
        VariableNames=[]
    end

    methods
        function self=solution(ckt,x,freq)



            self.Circuit=ckt;
            self.VariableNames=ckt.VariableNames;
            if nargin>1
                self.X=x;
                if nargin>2

                    self.Frequencies=freq;
                end
            end
        end

        function[out,idx,row,col]=v(self,nodeName,freq,thresh)
            validateattributes(nodeName,{'char','string'},...
            {'nonempty','scalartext'},'','nodeName')
            if nargin>2
                validateattributes(freq,{'numeric'},...
                {'nonempty','nonnegative','scalar'},'','freq')
            end

            out=self.X(self.Circuit.NumBranches+1:end,:);
            i=self.Circuit.NodeMap(nodeName)-1;
            out=out(i,:);
            if nargin>=3
                tol=eps(max(self.Frequencies));
                jpos=abs(freq-self.Frequencies)<=tol;
                if freq~=0
                    jneg=abs(freq+self.Frequencies)<=tol;
                else
                    jneg=[];
                end
                if any(jpos)
                    if any(jneg)
                        warning('two matching freqs')
                        out=out(:,jpos)+conj(out(:,jneg));
                    else
                        col=find(jpos);
                        out=out(:,jpos);
                    end
                else
                    if any(jneg)
                        col=find(jneq);
                        out=conj(out(:,jneg));
                    else
                        error('no matching freq')
                    end
                end
            else
                col=1:length(self.Frequencies);
            end
            m=self.Circuit.NumBranches+self.Circuit.NumNodes-1;
            row=i+self.Circuit.NumBranches;
            idx=row+(col-1)*m;
            if nargin==4
                re=real(out);
                im=imag(out);
                re(abs(re)<=thresh)=0;
                im(abs(im)<=thresh)=0;
                out=complex(re,im);
            end
        end

        function[out,idx,row,col]=i(self,branchName,freq)
            validateattributes(branchName,{'char','string'},...
            {'nonempty','scalartext'},'','branchName')
            if nargin>2
                validateattributes(freq,{'numeric'},...
                {'nonempty','nonnegative','scalar'},'','freq')
            end

            out=self.X(1:self.Circuit.NumBranches,:);
            i=strcmpi(self.VariableNames,branchName);
            out=out(i,:);
            if nargin==3
                tol=eps(max(self.Frequencies));
                jpos=abs(freq-self.Frequencies)<=tol;
                if freq~=0
                    jneg=abs(freq+self.Frequencies)<=tol;
                else
                    jneg=[];
                end
                if any(jpos)
                    if any(jneg)
                        warning('two matching freqs')
                        out=out(:,jpos)+conj(out(:,jneg));
                    else
                        col=find(jpos);
                        out=out(:,jpos);
                    end
                else
                    if any(jneg)
                        col=find(jneg);
                        out=conj(out(:,jneg));
                    else
                        error('no matching freq')
                    end
                end
            else
                col=1:length(self.Frequencies);
            end
            m=self.Circuit.NumBranches+self.Circuit.NumNodes-1;
            row=find(i,1);
            idx=row+(col-1)*m;
        end
    end
end
