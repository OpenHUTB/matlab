

classdef History<handle
    properties
Data
StartingIndex
    end

    properties(SetAccess=private)
DelayedVariables

Offset
Scale
    end

    methods




        function o=History(step,num_freqs,delayed_variables,delays)
            max_delay=max([0;delays(:)]);

            history_length=ceil(max_delay/step)+1;
            num_states=length(delayed_variables)*(2*num_freqs-1);

            assert(length(delays)==length(delayed_variables),'one delay value per variable');
            assert(history_length<1e4&num_states*history_length<1e6,'the history is too long');

            o.Data=zeros(length(delayed_variables),2*num_freqs-1,history_length);
            o.DelayedVariables=delayed_variables;

            assert(step>0&all(delays>=0),'time step and delays should be positive');

            offset=delays/step;
            left=floor(offset);
            scale=offset-left;
            scale(left==0)=1;

            o.Offset=left-1;
            o.Scale=scale;

            o.initialize;
        end

        function push_back(o,X)
            if isempty(o.DelayedVariables)
                return;
            end
            assert(size(X,2)==size(o.Data,2),'input data size is incorrect');
            o.StartingIndex=o.index(-1);
            o.Data(:,:,o.StartingIndex)=X(o.DelayedVariables,:);
        end





        function Z=interpolate(o)
            n=size(o.Data,1);
            Z=zeros(n,size(o.Data,2));
            if isempty(Z)
                return;
            end

            for i=1:n
                a=o.Scale(i);
                offset=o.Offset(i);
                Z(i,:)=(1-a)*o.Data(i,:,o.index(offset))+a*o.Data(i,:,o.index(offset+1));
            end
        end





        function Z=convolve(o,impulse)
            num_variables=size(o.Data,1);
            num_freqs=(size(o.Data,2)+1)/2;

            assert(num_variables==size(impulse,1)&num_freqs==size(impulse,2),'impulse response size does not match history')
            Z=zeros(num_variables,num_freqs);
            if isempty(Z)
                return;
            end

            N=min(size(o.Data,3),size(impulse,3))-1;




            for i=1:N
                k=o.index(i-1);
                d=o.Data(:,:,k);
                data=[d(:,1),d(:,2:num_freqs)+1j*d(:,num_freqs+1:end)];

                imp=impulse(:,:,i+1);

                Z=Z+data.*imp;
            end



        end




        function i=index(o,offset)
            n=size(o.Data,3);
            assert(all(o.StartingIndex>0&&o.StartingIndex<=n)&&all(offset<=n),'incorrect indices')

            i=mod(o.StartingIndex+offset-1,n)+1;
        end




        function initialize(o,varargin)
            o.StartingIndex=1;
            if isempty(varargin)
                o.Data=zeros(size(o.Data));
            else
                X=varargin{1};
                assert(size(X,2)==size(o.Data,2),'input data size is incorrect');
                if(size(X,3)==1)
                    o.Data=repmat(X(o.DelayedVariables,:),[1,1,size(o.Data,3)]);
                else
                    o.Data(:,:,1:size(X,3))=X(o.DelayedVariables,:,:);
                end
            end
        end

    end
end