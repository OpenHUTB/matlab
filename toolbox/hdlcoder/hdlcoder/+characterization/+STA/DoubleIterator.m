classdef DoubleIterator<handle



    properties
        m_iterator1;
        m_iterator2;
    end

    methods
        function self=DoubleIterator(iter1,iter2)
            self.m_iterator1=iter1;
            self.m_iterator2=iter2;
            self.reset();
        end


        function self=begin(self)
            self.m_iterator1.begin();
            self.m_iterator2.begin();
        end

        function bv=hasCurrent(self)
            bv=self.m_iterator1.hasCurrent()&&self.m_iterator2.hasCurrent();

        end

        function item=current(self)
            i1=self.m_iterator1.current();
            i2=self.m_iterator2.current();
            item={i1,i2};
        end

        function self=next(self)

            if(~self.m_iterator1.hasCurrent())
                error('end of iterator');
            end

            if(~self.m_iterator2.hasCurrent())
                error('end of iterator');
            end

            self.m_iterator2.next();

            if(~self.m_iterator2.hasCurrent())
                self.m_iterator1.next();
                if(self.m_iterator1.hasCurrent())
                    self.m_iterator2.begin();
                end
            end

        end

        function self=reset(self)
            self.m_iterator1.reset();
            self.m_iterator2.reset();
        end

    end

end

