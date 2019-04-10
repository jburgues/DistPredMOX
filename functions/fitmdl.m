function mdl = fitmdl(x,y,logx,logy,order)
    if logx
        x = log10(x(:));
    else
        x = x(:);
    end
    if logy
        y = log10(y(:));
    else
        y = y(:);
    end
    p = polyfit(x,y,order);
    
    mdl.coeffs = p;
    mdl.logx = logx;
    mdl.logy = logy;
    mdl.order = order;
end