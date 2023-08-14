classdef StepIterator<handle





    properties
m_currentValue
m_start
        m_end;
        m_step;

    end

    methods
        function self=StepIterator(varargin)
            n=numel(varargin);
            if n==3
                starti=varargin{1};
                endi=varargin{2};
                stepi=varargin{3};
            elseif n==1

                    ar=varargin{1};

                    if iscell(ar)
                        ar=ar{1};
                    end

                    if iscell(ar)
                        ar=ar{1};
                    end


                    if numel(ar)~=3
                        error('Invalid Arguments');
                    end
                    starti=ar(1);
                    endi=ar(2);
                    stepi=ar(3);
                end
            end
            self.m_start=starti;
            self.m_end=endi;
            self.m_step=stepi;
            self.reset();
        end


        function self=begin(self)
            self.m_currentValue=self.m_start;
        end

        function bv=hasCurrent(self)
            bv=self.m_currentValue<=self.m_end;
        end

        function item=current(self)

            item=self.m_currentValue;
        end

        function self=next(self)

            self.m_currentValue=self.m_currentValue+self.m_step;

        end

        function self=reset(self)
            self.m_currentValue=self.m_start;
        end

    end

end

