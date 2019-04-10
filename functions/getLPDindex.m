function f = getLPDindex(fc, cfg)

f = (4 + (fc-1)*cfg.n_thr) : (3 + fc*cfg.n_thr);