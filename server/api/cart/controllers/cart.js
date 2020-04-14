'use strict';

const {parseMultipartData,  sanitizeEntity } = require('strapi-utils');
/**
 * Read the documentation (https://strapi.io/documentation/3.0.0-beta.x/concepts/controllers.html#core-controllers)
 * to customize this controller
 */

module.exports = {
    
    async update(ctx) {
        let entity;

        const {products} = ctx.request.body;

        return strapi.services.cart.update(ctx.params, {
            products: JSON.parse(products)
        });
        // if (ctx.is('multipart')) {
        //   const { data, files } = parseMultipartData(ctx);
        //   entity = await strapi.services.restaurant.update(ctx.params, data, {
        //     files,
        //   });
        // } else {
        //   entity = await strapi.services.restaurant.update(
        //     ctx.params,
        //     ctx.request.body
        //   );
        // }
    
        // return sanitizeEntity(entity, { model: strapi.models.restaurant });
      },

};
