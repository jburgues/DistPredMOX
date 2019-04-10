function yp = evalmdl(mdl, x)
	% Evaluate model mdl at points defined in vector x.
    if mdl.logx
        x = log10(x(:));
    else
        x = x(:);
    end
    ypred = polyval(mdl.coeffs,x);
    if mdl.logy
        yp = 10.^ypred;
    else
        yp = ypred;
    end
end