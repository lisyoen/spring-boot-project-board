package com.fastcampus.projectboard.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.List;

@RequestMapping("/articles")
@Controller
public class ArticleController {

    @GetMapping
    public String getArticles(ModelMap map) {
        map.addAttribute("articles", List.of());

        return "articles/index";
    }

    @GetMapping("/{article-id}")
    public String getArticle(@PathVariable("article-id") Long articleId, ModelMap map) {
        map.addAttribute("article", "null"); // TODO 실제 데이터 넣어줘야 함
        map.addAttribute("articleComments", List.of());

        return "articles/detail";
    }
}
