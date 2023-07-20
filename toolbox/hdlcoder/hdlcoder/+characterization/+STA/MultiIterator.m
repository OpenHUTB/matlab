classdef MultiIterator<handle





    properties
        m_iterator;
        m_depth;
    end

    methods
        function self=MultiIterator(IteratorType,varargin)

            argList=varargin;
            numArgs=numel(argList);

            self.m_depth=numArgs;

            if(numArgs<=0)
                error('Invalid Args for Iterator');
            end

            if(numArgs==1)
                evalc(['iter1 = ',IteratorType,'(argList);']);
                self.m_iterator=iter1;
                return;
            end
            if numArgs==2

                evalc(['iter1 = ',IteratorType,'(argList{1});']);
                evalc(['iter2 = ',IteratorType,'(argList{2});']);
                self.m_iterator=characterization.STA.DoubleIterator(iter1,iter2);

            else

                evalc(['iter1 = ',IteratorType,'(argList{1})']);
                iter2=characterization.STA.MultiIterator(IteratorType,argList{2:end});
                self.m_iterator=characterization.STA.DoubleIterator(iter1,iter2);
            end

        end

        function val=hasCurrent(self)
            val=self.m_iterator.hasCurrent();
        end

        function val=current(self)
            childCurrent=self.m_iterator().current();

            if(self.m_depth==1)

                val={childCurrent};
            elseif(self.m_depth==2)
                    val=childCurrent;
                else
                    val={childCurrent{1},childCurrent{2}{1:end}};
                end

            end
        end

        function self=next(self)
            self.m_iterator.next();
        end

        function self=reset(self)
            self.m_iterator.reset();
        end

        function self=begin(self)
            self.m_iterator.begin();
        end

    end

end

