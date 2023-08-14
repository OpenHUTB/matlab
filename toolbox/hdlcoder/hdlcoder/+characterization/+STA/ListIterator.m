classdef ListIterator<handle





    properties
m_list
m_currentIndex
        m_numElements;
    end

    methods
        function self=ListIterator(list)
            self.m_list=list;
            self.reset();
        end

        function self=setList(self,list)
            self.m_list=list;
            self.reset();
        end

        function self=begin(self)
            self.m_currentIndex=1;

        end

        function bv=hasCurrent(self)
            bv=self.m_currentIndex<=self.m_numElements;
        end

        function item=current(self)
            item=self.m_list(self.m_currentIndex);
        end

        function self=next(self)
            self.m_currentIndex=self.m_currentIndex+1;
        end

        function self=reset(self)
            self.m_currentIndex=1;
            self.m_numElements=numel(self.m_list);
        end

    end

end

