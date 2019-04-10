function h = FilterLPD_Javier(Fpass, Fstop, Att, Dev, Fs)
    [N,Fo,Ao,W] = firpmord([Fpass, Fstop], Att, Dev, Fs);
    b = firpm(N,Fo,Ao,W);
    h = conv(b, [1 -1]);