function[delta_gradLag,delta_xDelta_gradLag]=dampingProcedure(delta_gradLag,delta_x,...
    HessDelta_x,delta_xDelta_gradLag,curvAlongDelta_x)














    if delta_xDelta_gradLag<0.2*curvAlongDelta_x

        theta=0.8*curvAlongDelta_x/(curvAlongDelta_x-delta_xDelta_gradLag);
        delta_gradLag=theta*delta_gradLag+(1.0-theta)*HessDelta_x;

        delta_xDelta_gradLag=delta_x'*delta_gradLag;
    end

