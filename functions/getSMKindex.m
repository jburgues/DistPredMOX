function f = getSMKindex(cfg)

f = (4 + cfg.n_fcut*cfg.n_thr) : (3 + (cfg.n_fcut+1)*cfg.n_thr);