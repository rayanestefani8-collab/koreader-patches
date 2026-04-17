-- 2-hide-titlebar-filebrowser.lua (CORRIGIDO)
-- KOReader user patch: Remove title bar apenas do FileManager / CoverBrowser

local TitleBar = require("ui/widget/titlebar")
local Menu     = require("ui/widget/menu")
local UIManager = require("ui/uimanager")

-- ── 1. Intercepta a criação do TitleBar com filtro rigoroso ──────────────────
local _orig_TitleBar_init = TitleBar.init
TitleBar.init = function(self, ...)
    _orig_TitleBar_init(self, ...)

    -- Verificamos se o widget pai é o FileManager ou se faz parte do fluxo do browser
    -- Evitamos aplicar se houver indicação de ser um "dialog" ou "popup"
    local is_browser = self.parent and (self.parent.name == "filemanager" or self.parent.name == "filesearcher")
    
    -- Se não conseguirmos detectar pelo pai, checamos o contexto do Menu
    if is_browser then
        self.getSize = function(_self)
            return { w = _self.dimen and _self.dimen.w or 0, h = 0 }
        end
        self.paintTo = function() end
        if self.dimen then self.dimen.h = 0 end
    end
end

-- ── 2. Devolve o espaço ao Menu apenas no FileManager ────────────────────────
local _orig_Menu_init = Menu.init
Menu.init = function(self, ...)
    _orig_Menu_init(self, ...)

    -- Filtro: Apenas menus que pertencem ao FileManager e NÃO são menus de toque/popups
    if self.title_bar and (self.name == "filemanager" or self.name == "filesearcher") then
        local tb = self.title_bar
        if tb.dimen then tb.dimen.h = 0 end
        tb.getSize = function(_self)
            return { w = _self.dimen and _self.dimen.w or 0, h = 0 }
        end
        tb.paintTo = function() end
    end
end

-- ── 3. Correção para Popups (Garante que o 'X' apareça) ──────────────────────
-- Esta parte garante que, se o widget for um Popup/Dialog, as dimensões sejam restauradas
local _orig_show = UIManager.show
UIManager.show = function(self, widget, ...)
    if widget and (widget.is_dialog or widget.name == "tweak_dialog") then
        -- Se por algum motivo o TitleBar aqui foi zerado, não aplicamos o patch
        if widget.title_bar and widget.title_bar.dimen and widget.title_bar.dimen.h == 0 then
            -- Resetar para o padrão do dispositivo se for um popup
            local Screen = require("device").screen
            widget.title_bar.dimen.h = 50 -- Altura padrão aproximada, o KOReader ajustará
        end
    end
    return _orig_show(self, widget, ...)
end
