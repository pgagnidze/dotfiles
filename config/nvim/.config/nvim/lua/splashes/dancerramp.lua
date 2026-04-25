local vim = vim
local M = {}

local WIDTH = 60
local DELAY = 100
local BRIGHT, MID, DIM = "#ffbb22", "#cc9911", "#664411"

local raw = {
  [[


                          'l~?+!'
                       `~jCLOwwwZv+
                     ^fQLQx<[CZZL]+~.
                     zLCww)'^xUun,^{[
                    ,wJZwwwwYmn1QYwwn~
                   "UwwwwwwwZQwmLOwZnm`
                  ;CwwwwwwwwwwwwwwZ]XU.
                 .Cwwwwwwwwwwwwww0zY(^
                 :wwwwwwwwwwwwwwL;.
                 .YwwwwwwwwwwwwJ,
                  "uZLwwwwwwwwu^
                    jQUmwwZUfi
                    lw].`<cz+.
                     Xz    >uJ['
                     (m`     ;jL)^
                     ~wi       "/Q/,
                     :mX)        ^)Lcu"
                      `"'          '^^

]],
  [[


                          .;<_<I.
                       'itCCZwwwOu<
                     '/LLQn~{LmmQ[_~
                     uLJww1.^nUvv,'}]
                    `mCwwwwmXLc/XYwwn-
                   'vwwwwwwwOOwwOOwZrw"
                  `cwwwwwwwwwwwwwwm}cC'
                  xwwwwwwwwwwwwwwZvX|^
                 .OwwwwwwwwwwwwwO>.
                  nwwwwwwwwwwww0!
                  `uOQwwwwwwwwJI
                    {ZXmwww0v-.
                    `0f',irU['
                     j0.   IfL(,
                     ?wI     ^(Qf,
                     iw~       `{Qj:
                     "mY)        `1Lcu"
                      `"'          '^^

]],
  [[


                           .":".
                        ^]uQwwwZY),
                      !rJQX1rZwwZj)>
                    .fZJOw?.`rQQv".+~
                    'OYZwwmzcLn?XLvmv/'
                    :mZwwwwwQOwwZQmw|w~
                   'YwwwwwwwwwwwwwwjtZ;
                   rwwwwwwwwwwwwwwUct;
                  ;wwwwwwwwwwwwwwJ^
                  ,mwwwwwwwwwwww0:
                   }mwmwwwwwwwwO>
                    iu0LwwwwwZj:
                     ,Zr})(zC].
                      vX    !jL|,
                      rJ'     ^(Q(`
                      zz        ,xL~
                     `OC)         ~Lzu"
                      `"'          '^^

]],
  [[


                          ;-{1{_:
                       .1CwwwwwwwU]`.
                      'zwwf!+UQQziI{Ju>
                     )JOww/I!XXrU_ijz]Z-
                      fwJCOwXUCcULQwwXJ|
                      ;zmYwwwwwwwwwwwwC^
                       fQQwwwwwwwwwwwwwX`
                       <mUZwwwwwwwwwwwwwY`
                        !uLmwwwwwwwwwwwwwr
                          l0wwwwwwwwwwwwwJ'
                           IQwwwwwwwwwwww|
                            ;Ywwwwwwwwwmu.
                              ~xLOZm0z(Jx
                             >rLt!..  >w_
                          ;|Cu+.     "Ju
                       ^}XX[^       iLx.
                     'n0XI         {ZC,
                      `"'          '^^

]],
  [[


                         I{xXXzx};
                       IXwwQZwwwwQfur?'
                      lOww?.`rQQf..+|nC,
                     <JQwwY)}Zf?L1|JmfO]
                      )wUC0wJCOwJJwwwwC:
                      `jmYwwwwwwwwwwwwwQ<
                       IwYwwwwwwwwwwwwwwm1
                        )OC0wwwwwwwwwwwwww{
                         ;|JmwwwwwwwwwwwwwU'
                           'fwwwwwwwwwwwwwx
                             ]ZwwwwwwwwwwX^
                              ,|CZLmwwZCCi
                               ,(Cu_<I:Qj
                            '-cJ{"   .vU`
                          !fLf!      fL:
                       "{Uc-'       f0l
                     'n0X:         (mY"
                      `"'          '^^

]],
  [[


                         i|cJCJv(!..
                       iJwmJQwwwwJrXX|,
                      lZww_ 'jQQ/'.+(t0:
                     ^JJmwJ/1mt-C(fLwzQ<
                      {mUJ0wCQLQQLwwwwQ>
                      ./mYwwwwwwwwwwwwwm(.
                       "mYwwwwwwwwwwwwwwwz^
                        ?0CLmwwwwwwwwwwwwwc
                         `[vmwwwwwwwwwwwwwm'
                            -Owwwwwwwwwwwwv
                             ;Xwwwwwwwwwwz^
                               ~rCLmmmCUCi
                               ;/Lri^.lZ)
                            `]XY[`   `Ju.
                          irL/I     'cY`
                       "1Jv_'      .nL,
                     'n0X:         |mX"
                      `"'          '^^

]],
  [[


                         i(vULUu)l
                       !UwmJQwwwwJrXz)"
                      lZww_.'jQQt..+(f0;
                     :CCmwU|1mf-L)fLwu0+
                      1wUJ0wCLL0LCwwwwQi
                      'tmYwwwwwwwwwwwwwZ1.
                       ,mYwwwwwwwwwwwwwwwv`
                        ]0CLmwwwwwwwwwwwwwu
                         ^}zmwwwwwwwwwwwwwZ'
                            ]Zwwwwwwwwwwwwu
                             lUwwwwwwwwwwz^
                              ._uLLmwmLUCi
                               ;|Lx>,'IO|
                            `]XY[`   `Uv.
                          irLtI     .vU`
                       "1Jv_'      .xL:
                     'n0X:         |mX"
                      `"'          '^^

]],
  [[


                         "]tuvn/-^
                       :umwmmwwwwOt({l
                      IQww}."xQQr`._jYz^
                     ?J0wwc]?Oj[L{{XZ}Z1
                      |wUC0wUUZZCUmwwwU;
                      ^xmYwwwwwwwwwwwwwu^
                       <wYwwwwwwwwwwwwwwC;
                       .n0CZwwwwwwwwwwwww0:
                         ~xQwwwwwwwwwwwwwwf
                           lCwwwwwwwwwwwww(
                            ^cwwwwwwwwwwwX`
                             .]Jwm0wwwwQC!
                               "fLz1{-lJv
                            .+uC(:    /0:
                          ltLr>      [Z<
                       "}Uz?`       1Z~
                     'n0X;         )mY"
                      `"'          '^^

]],
  [[



                         l)uYUYn1l
                       :nQJL0wwwwLf;
                     ifQLQ+.'fQQn..>:
                    .zLLwwU(1Ox?UX{Jvv^
                    .OYwwwwwJCwwOQ0w)O(
                     YmwwwwwwwwwwwwQ]m?
                    iwwwwwwwwwwwwwwvn~
                    vwwwwwwwwwwwwwQ`
                   .Owwwwwwwwwwwww}
                    nwwwwwwwwwwwwC'
                    ^vwwZwwwwwwwU:
                      inLQwww0L1.
                       >w+,,`I1YX-
                       ~w<      iUX,
                      `Uc.       'uC^
                     'YZ/         'JJu"
                      `"'          '^^

]],
  [[


                           ,!>i,
                        I|UCwwww0r!
                     .1CLQv-(Qww01]~
                    .xQJww{.^nJzv,.]?
                    'mUmwwwOzCv(XUOwn}
                    /wwwwwww0OwwZ0wmfw;
                   (wwwwwwwwwwwwwwm{uL`
                  ]wwwwwwwwwwwwwwmvX|"
                  zwwwwwwwwwwwwwm]
                  (wwwwwwwwwwwwm[
                  .rZmOwwwwwwwZ[
                    >wYwwwwmJ|,
                     cU,li/J|,
                     ?wI   "1Cxl
                     Iw-     .?Jv!
                     :w]       .]CuI
                     ,mU)        .}Lcu"
                      `"'          '^^

]],
}

M.frames = {}
for i, blob in ipairs(raw) do
  local rows = {}
  for _, line in ipairs(vim.split(blob, "\n", { plain = true })) do
    rows[#rows + 1] = line .. string.rep(" ", math.max(0, WIDTH - #line))
  end
  M.frames[i] = rows
end

local color_by_byte = {}
for b = 0, 255 do color_by_byte[b] = DIM end
color_by_byte[string.byte(" ")] = nil
for _, range in ipairs({ { "0", "9" }, { "a", "z" }, { "A", "Z" } }) do
  for b = string.byte(range[1]), string.byte(range[2]) do
    color_by_byte[b] = MID
  end
end
for c in ("wWmMQOLCJYZUKEBGNDHRPAX0"):gmatch(".") do
  color_by_byte[c:byte()] = BRIGHT
end

local ns = vim.api.nvim_create_namespace("dancer_paint")
local hl_cache = {}
local function get_hl(fg)
  if hl_cache[fg] then return hl_cache[fg] end
  local name = "Dancer_" .. fg:sub(2)
  vim.api.nvim_set_hl(0, name, { fg = fg })
  hl_cache[fg] = name
  return name
end

function M.attach(buf)
  local frame1 = M.frames[1]
  local anchor_row, anchor_text, anchor_col
  for i, l in ipairs(frame1) do
    local s = vim.trim(l)
    if s ~= "" then
      anchor_row, anchor_text = i, s
      anchor_col = l:find(s, 1, true)
      break
    end
  end
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local start_row, pad_bytes
  for i, l in ipairs(lines) do
    local pos = l:find(anchor_text, 1, true)
    if pos then
      start_row = i - anchor_row
      pad_bytes = pos - anchor_col
      break
    end
  end
  if not start_row then return end

  local pad_str = string.rep(" ", pad_bytes)
  local padded_frames = {}
  for fi, f in ipairs(M.frames) do
    local p = {}
    for i, l in ipairs(f) do p[i] = pad_str .. l end
    padded_frames[fi] = p
  end

  local function paint(idx)
    if not vim.api.nvim_buf_is_valid(buf) then return false end
    local frame = M.frames[idx]
    local padded = padded_frames[idx]
    vim.bo[buf].modifiable = true
    vim.api.nvim_buf_set_lines(buf, start_row, start_row + #padded, false, padded)
    vim.bo[buf].modifiable = false
    vim.api.nvim_buf_clear_namespace(buf, ns, start_row, start_row + #padded)
    for row_i, line in ipairs(frame) do
      local buf_row = start_row + row_i - 1
      local len = #line
      local col = 1
      while col <= len do
        local fg = color_by_byte[line:byte(col)]
        if fg then
          local e = col
          while e < len and color_by_byte[line:byte(e + 1)] == fg do
            e = e + 1
          end
          vim.api.nvim_buf_set_extmark(buf, ns, buf_row, pad_bytes + col - 1, {
            end_col = pad_bytes + e,
            hl_group = get_hl(fg),
            priority = 200,
          })
          col = e + 1
        else
          col = col + 1
        end
      end
    end
    return true
  end

  local timer = vim.uv.new_timer()
  local idx = 1
  timer:start(0, DELAY, vim.schedule_wrap(function()
    if not paint(idx) then
      timer:stop()
      timer:close()
      return
    end
    idx = (idx % #M.frames) + 1
  end))
end

return M
